from sqlglot import parse_one, exp
from algorithm_examples.Lero.source.utils import PlanCardReplacer
from algorithm_examples.Lero.source.card_picker import CardPicker

class CardsPickerModel():
    def __init__(self, subqueries, rows) -> None:
        self.swing_factor_lower_bound = 0.1**2
        self.swing_factor_upper_bound = 10**2
        self.swing_factor_step = 10
        # print("swing_factor_lower_bound", self.swing_factor_lower_bound)
        # print("swing_factor_upper_bound", self.swing_factor_upper_bound)
        # print("swing_factor_step", self.swing_factor_step)
        self.tables = [QueryMetaData(q).tables for q in subqueries]
        self.rows = rows
        self.isMultiTables = [True if len(table) > 1 else False for table in self.tables]  # [F, ..., F, T, T, ..., T]
        self.join_rel_tables = [x for x, b in zip(self.tables, self.isMultiTables) if b == True]
        self.join_rel_rows = [x for x, b in zip(self.rows, self.isMultiTables) if b == True]
        self.base_rel_rows = [x for x, b in zip(self.rows, self.isMultiTables) if b == False]
        if len(self.join_rel_rows) > 0:
            self.card_picker = CardPicker(self.join_rel_rows, self.join_rel_tables,
                                    self.swing_factor_lower_bound, self.swing_factor_upper_bound, self.swing_factor_step)
        else:
            self.card_picker = None
        self.plan_card_replacer = PlanCardReplacer(self.join_rel_tables, self.join_rel_rows)

    def get_cards(self):
        if self.card_picker:
            finish = self.card_picker.next()
            new_cards = self.base_rel_rows + self.card_picker.get_card_list()
            return finish, new_cards
        else:
            # No join_rel_rows, we do not need card_picker
            return True, self.base_rel_rows
        
    
    # Lero guides the optimizer to generate different plans by changing cardinalities,
    # but row count will be used as the input feature when predicting the plan score.
    # So we need to restore all the row counts to the original values before feeding the model.
    def replace(self, plan):
        if "Plan" in plan:
            plan = plan["Plan"]
        self.plan_card_replacer.replace(plan)

class QueryMetaData():
    def __init__(self, queryString, replace_alias=True) -> None:
        self.raw = queryString
        self.expression = parse_one(self.raw)
        self.tables = []
        self.table_alias = []
        self.names_to_alias = {}
        self.alias_to_names = {}
        self._parse_table()
        self.replace_alias = replace_alias
        self.sql_without_alias = self.raw
        self.expression_origin = self.expression
        if self.replace_alias:
            self._replace_table_alias()
        self.conditions = [] # Element Type: sqlglot.expressions.EQ. If need str type, use sql() method 
        self.joins = []      # Element Type: sqlglot.expressions.EQ. If need str type, use sql() method 
        self._parse_predicates()
        
    def _parse_table(self):
        for table in self.expression.find_all(exp.Table, bfs=False):
            self.tables.append(table.name)
            if table.alias:
                self.table_alias.append(table.alias)
                self.names_to_alias[table.name] = table.alias
                self.alias_to_names[table.alias] = table.name
                
    def _replace_table_alias(self):
        for k, v in self.alias_to_names.items():
            # print(k, v)
            self.sql_without_alias = self.sql_without_alias.replace(k+'.', v+'.')
        self.expression = parse_one(self.sql_without_alias)
        while self.expression.find(exp.TableAlias):
            self.expression.find(exp.TableAlias).pop()
        # print(self.expression)
    
    def _parse_predicates(self):
        for pre in self.expression.find_all(exp.Predicate, bfs=False):
            columns = list(pre.find_all(exp.Column, bfs=False))
            if len(columns)== 1:
                self.conditions.append(pre)
            elif len(columns) == 2:
                self.joins.append(pre)
            
    def __str__(self):
        return '\n'.join(["{}: {}".format(k, "[{}]".format(', '.join([s.sql() for s in v])) if (isinstance(v, list) and len(v) != 0 and hasattr(v[0], 'sql')) else v) for k, v in self.__dict__.items()])