/*---------------------------------------------------------
*  subplanquery.h
*  	     Routines to generate sub-plan query to server and 
*   receive its cardinality or selectivity by http service
*
*  Copyright (c) 2023, Damo Academy of Alibaba Group
*-----------------------------------------------------------
*/

#include "pilotscope/subplanquery.h"

#define IsNumType(typid)  \
	((typid) == INT8OID || \
	 (typid) == INT2OID || \
	 (typid) == INT4OID || \
	 (typid) == FLOAT4OID || \
	 (typid) == FLOAT8OID || \
	 (typid) == NUMERICOID)

typedef struct DeparseTblRef
{
	int rtindex;       /* the index of the rangetblentry in root->simple_rte_array */
	RTEKind rtekind;   /* the kind of the rangetblentry */
	bool visit;        /* whether to visit */
	char *rname;       /* the name of the rangetblentry */
	char *alias;       /* the alias of the rangetblentry */
}DeparseTblRef;

typedef struct JoinClause
{ 
	bool swap;              /* for on_join_clause, if true, swap left and right order */
	JoinType jointype;      /* jointype */ 
	Relids left_relids;     /* for on_join_clause, relids in left side of Join  */ 
	Relids right_relids;    /* for on_join_clause, relids in right side of Join  */
	RestrictInfo *join_clause;     /* join restricts */
}JoinClause;

typedef struct JoinClauseGroup
{
	Relids relids;     
	List* join_clauses;    /* List of JoinClause */ 
}JoinClauseGroup;

typedef struct DeparseCxt
{
	DeparseTblRef **all_rels;       /* array of DeparseTblRef*, all relids in cur joinrel */
	Relids where_join_rels;        /* List of RangeTblRef */
	List* where_join_clauses;      /* List of JoinClause */ 
	List* on_join_clauses;         /* List of JoinClauseGroup,  on_join_clauses->relids is all relids in current group */
	List* ppi_clauses;  /* required_outer_clauses->relids is required_outer */
}DeparseCxt;

StringInfo sub_query;
// if true, the prefix = " where ", else the prefix = " and "
static bool isWhereOrAnd;
static bool isSwap = false;  // for lexicographic order of join clause
bool rel_first; 
DeparseCxt* context;

static int joinclause_relation_order_compare(const ListCell *a, const ListCell *b);
static void get_expr(const Node *expr, PlannerInfo *root);
static void get_restrictclauses(PlannerInfo *root, List *clauses);
static void get_rels_for_deparse (PlannerInfo *root, Relids relids, bool visit);
static void get_rels_from_dtr (PlannerInfo *root, Relids relids, bool comma);
static void get_relids (PlannerInfo *root, Relids relids);
static void get_parameterized_ndv_sql(PlannerInfo *root, Relids relids, List *param_clauses);
static void append_join_clause_to_context(PlannerInfo *root, RelOptInfo *join_rel, JoinType jointype, List *clauses);
static void get_on_join_restrictclauses(PlannerInfo *root, JoinClauseGroup* jg);
static void get_path(PlannerInfo *root, RelOptInfo *rel, Path *path);
static void get_path_from_rel (PlannerInfo *root, RelOptInfo *rel);
static void get_join_info (PlannerInfo *root);
static void get_base_restrictclauses (PlannerInfo *root, Relids relids);
static DeparseTblRef **makeDeparseTblRef(int num);
static Relids get_relids_only_in_rangetbl(Node *jtnode);

/* 
 * Compare the relation order of join clause.
 */
static int
joinclause_relation_order_compare(const ListCell *a, const ListCell *b)
{
	JoinClause	   *jc1 = (JoinClause *) lfirst(a);
	JoinClause	   *jc2 = (JoinClause *) lfirst(b);
	int			cmp;

	Relids r1 = bms_union(jc1->left_relids, jc1->right_relids);
	Relids r2 = bms_union(jc2->left_relids, jc2->right_relids);
	return bms_compare(r1, r2);
}



/* 
 * transform expression into string and append them to the subquery string.
 */
static void
get_expr(const Node *expr, PlannerInfo *root)
{
    if (expr == NULL)
    {
        // printf("<>");
        return;
    }
    switch (nodeTag(expr)){
		case T_Var:
		{
			const Var  *var = (const Var *) expr;
        	char	*relname,
        	        *attname;

        	switch (var->varno)
        	{
        	    case INNER_VAR:
        	        relname = "INNER";
        	        attname = "?";
        	        break;
        	    case OUTER_VAR:
        	        relname = "OUTER";
        	        attname = "?";
        	        break;
        	    case INDEX_VAR:
        	        relname = "INDEX";
        	        attname = "?";
        	        break;
        	    default:
        	    {
					const List *rtable = root->parse->rtable;
        	        RangeTblEntry *rte;
        	        Assert(var->varno > 0 &&
        	               (int) var->varno <= list_length(rtable));
        	        rte = rt_fetch(var->varno, rtable);
        	        relname = rte->eref->aliasname;
        	        attname = get_rte_attribute_name(rte, var->varattno);
        	    }
        	        break;
        	}
			appendStringInfo(sub_query, "%s.%s", relname, attname);
			break;
		}
		case T_Const:
		{
			const Const *c = (const Const *) expr;
        	Oid			typoutput;
        	bool		typIsVarlena;
        	char	   *outputstr;
        	if (c->constisnull)
        	{
        	    printf("NULL");
        	    return;
			}

        	getTypeOutputInfo(c->consttype,
        	                  &typoutput, &typIsVarlena);

        	outputstr = OidOutputFunctionCall(typoutput, c->constvalue);
			/* ToDo: See comments in deparseConst() and get_const_expr() */

			if (c->consttype == BOOLOID){
				if (strcmp(outputstr, "t") == 0)
					appendStringInfoString(sub_query, "true");
				else
					appendStringInfoString(sub_query, "false");
			}else if(IsNumType(c->consttype)){
				appendStringInfoString(sub_query, outputstr);
			}else{
				// appendStringInfo(sub_query, "'%s'", outputstr);
				const char *valptr;
				appendStringInfoChar(sub_query, '\'');
				for (valptr = outputstr; *valptr; valptr++){
					char ch = *valptr;
					if (SQL_STR_DOUBLE(ch, true)){
						appendStringInfoChar(sub_query, ch);
					}
					appendStringInfoChar(sub_query, ch);
				}
				appendStringInfoChar(sub_query, '\'');
			}

        	pfree(outputstr);
			break;
		}
		case T_Param:
		{
			const Param *param = (const Param *) expr;

			// convert Param to Const

			/* see if we can replace the Param */
			Node	   *subst = estimate_expression_value(root, param);

			if (IsA(subst, Const))
			{
				/* bool constant is pretty easy... */
				Const	   *con = (Const *) subst;
				get_expr(con, root);
			}
			else
			{
				/* XXX any way to do better than default? */
				printf("\nError!\n");
			}

			// convert Param to Var
			if (param->paramkind == PARAM_EXEC){
				while (root->parent_root){
					PlannerInfo *ancestor = root->parent_root;
					ListCell   *ppl;
					PlannerParamItem *pitem;
					foreach(ppl, ancestor->plan_params){
						pitem = (PlannerParamItem *) lfirst(ppl);
						if (pitem->paramId == param->paramid){
							if (IsA(pitem->item, Var)){
								// printf("line 128: I am Var\n");
								Node *pvar = pitem->item;
								appendStringInfoString(sub_query, "/* ");
								get_expr(pvar, ancestor);
								appendStringInfoString(sub_query, " */");
							}else{
								printf("line 132: I am not Var\n");
								Node *pvar = pitem->item;
								appendStringInfoString(sub_query, "/* ");
								get_expr(pvar, ancestor);
								appendStringInfoString(sub_query, " */");
							}
						}
					}
					root = ancestor;
				}
				
			}
			break;
		}
		case T_OpExpr:
		{
			const OpExpr *e = (const OpExpr *) expr;
        	char	   *opname;
			HeapTuple	tuple;
			Form_pg_operator form;
			char		oprkind;
			ListCell   *lc;
			/* Retrieve information about the operator from system catalog. */
			tuple = SearchSysCache1(OPEROID, ObjectIdGetDatum(e->opno));
			if (!HeapTupleIsValid(tuple))
				elog(ERROR, "cache lookup failed for operator %u", e->opno);
			form = (Form_pg_operator) GETSTRUCT(tuple);
			oprkind = form->oprkind;
			opname = NameStr(form->oprname);
			if (strcmp(opname, "~~") == 0){
				opname = "LIKE";
			}
			if (strcmp(opname, "!~~") == 0){
				opname = "NOT LIKE";
			}

			/* Sanity check. */
			Assert((oprkind == 'r' && list_length(e->args) == 1) ||
				   (oprkind == 'l' && list_length(e->args) == 1) ||
				   (oprkind == 'b' && list_length(e->args) == 2));
			
			// B.k = A.k convert to A.k = B.k
			isSwap = false;
			if (strcmp(opname, "=") == 0){
				Expr	   *ex1 = (Expr *) lfirst(list_head(e->args));
				Expr	   *ex2 = (Expr *) lfirst(list_tail(e->args));
				if (nodeTag(ex1) == T_Var && nodeTag(ex2) == T_Var){
					if (((Var *) ex1)->varno > ((Var *) ex2)->varno)
						isSwap = true;
				}
			}

			if (!isSwap){
				/* Deparse left operand. */
				if (oprkind == 'r' || oprkind == 'b')
				{
					lc = list_head(e->args);
					get_expr(lfirst(lc), root);
				}
				appendStringInfo(sub_query, " %s ", opname);
				/* Deparse right operand. */
				if (oprkind == 'l' || oprkind == 'b')
				{
					lc = list_tail(e->args);
					get_expr(lfirst(lc), root);
				}
			}else{
				/* Deparse left operand. */
				if (oprkind == 'r' || oprkind == 'b')
				{
					lc = list_tail(e->args);
					get_expr(lfirst(lc), root);
				}
				appendStringInfo(sub_query, " %s ", opname);
				/* Deparse right operand. */
				if (oprkind == 'l' || oprkind == 'b')
				{
					lc = list_head(e->args);
					get_expr(lfirst(lc), root);
				}
			}
			
			ReleaseSysCache(tuple);
			break;
		}
		case T_RelabelType:
		{
			expr = ((RelabelType *) expr)->arg;
			get_expr(expr, root);
			break;
		}
		case T_BoolExpr:
		{	
			BoolExpr   *boolexpr = (BoolExpr *) expr;
			int			nargs = list_length(boolexpr->args);
			int			off=0;
			char       *boolopname;
			ListCell   *lc;
			switch (boolexpr->boolop){
				case AND_EXPR:
					Assert(nargs >= 2);
					boolopname = "AND";
					break;
				case OR_EXPR:
					Assert(nargs >= 2);
					boolopname = "OR";
					break;
				case NOT_EXPR:
					Assert(nargs == 1);
					boolopname = "NOT";
					appendStringInfo(sub_query, "%s ", boolopname);
					break;
			}
			foreach(lc, boolexpr->args){
				Expr	   *arg = (Expr *) lfirst(lc);
				if (off != 0){
					appendStringInfo(sub_query, " %s ", boolopname);
				}
				appendStringInfoChar(sub_query, '(');
				get_expr(arg, root);
				appendStringInfoChar(sub_query, ')');
				off++;
			}
			break;
		}
		case T_NullTest:
		{
			NullTest   *ntest = (NullTest *) expr;
			Expr	   *arg = ntest->arg;
			get_expr(arg, root);
			if (ntest->argisrow || !type_is_rowtype(exprType((Node *) ntest->arg)))
			{
				if (ntest->nulltesttype == IS_NULL)
					appendStringInfoString(sub_query, " IS NULL");
				else
					appendStringInfoString(sub_query, " IS NOT NULL");
			}
			else
			{
				if (ntest->nulltesttype == IS_NULL)
					appendStringInfoString(sub_query, " IS NOT DISTINCT FROM NULL");
				else
					appendStringInfoString(sub_query, " IS DISTINCT FROM NULL");
			}
			break;
		}
		case T_ScalarArrayOpExpr:
		{
			// scalar op ANY/ALL (array)
			// The operator must yield boolean.
			// It is applied to the left operand and each element of the righthand array,
			// and the results are combined with OR or AND (for ANY or ALL respectively).
			// The node representation is almost the same as for the underlying operator (function).

			// ToDo: support function
			ScalarArrayOpExpr *opexpr = (ScalarArrayOpExpr *) expr;
			Expr	   *scalararg;
			Expr	   *arrayarg;  
			char	   *opname;
			bool		useOr = opexpr->useOr; /* true for ANY, false for ALL */


			Assert(list_length(opexpr->args) == 2);
			scalararg = (Expr *) linitial(opexpr->args);
			arrayarg = (Expr *) lsecond(opexpr->args);

			get_expr(scalararg, root);
			opname = get_opname(opexpr->opno);
			if (strcmp(opname, "~~") == 0){
				opname = "LIKE";
			}
			if (strcmp(opname, "!~~") == 0){
				opname = "NOT LIKE";
			}
			if ((strcmp(opname, "=") == 0) && useOr){
				appendStringInfoString(sub_query, " IN ");
			}else{
				appendStringInfo(sub_query, " %s  %s ", opname, useOr ? "ANY" : "ALL");
			}
			if (arrayarg && IsA(arrayarg, Const)){
				Datum		arraydatum = ((Const *) arrayarg)->constvalue;
				bool		arrayisnull = ((Const *) arrayarg)->constisnull;
				Oid			nominal_element_type = get_base_element_type(exprType(arrayarg));
				Oid			nominal_element_collation = exprCollation(arrayarg);
				ArrayType  *arrayval;
				int16		elmlen;
				bool		elmbyval;
				char		elmalign;
				int			num_elems;
				Datum	   *elem_values;
				bool	   *elem_nulls;
				int			i;
				if (arrayisnull)		/* qual can't succeed if null array */
					appendStringInfoString(sub_query, "( )");
				arrayval = DatumGetArrayTypeP(arraydatum);
				get_typlenbyvalalign(ARR_ELEMTYPE(arrayval),
									 &elmlen, &elmbyval, &elmalign);
				deconstruct_array(arrayval,
								  ARR_ELEMTYPE(arrayval),
								  elmlen, elmbyval, elmalign,
								  &elem_values, &elem_nulls, &num_elems);
				appendStringInfoChar(sub_query, '(');
				for (i = 0; i < num_elems; i++){
					if (i != 0){
						appendStringInfoString(sub_query, ", ");
					}
					Const *elem = makeConst(nominal_element_type,
										-1,
										nominal_element_collation,
										elmlen,
										elem_values[i],
										elem_nulls[i],
										elmbyval);
					get_expr(elem, root);
				}
				appendStringInfoChar(sub_query, ')');
			}
			break;
		}
		case T_SubPlan:
		{
			const SubPlan *sp = (const SubPlan *) expr;
			int subplan_id = sp->plan_id;
			printf("line 334: I am SubPlan\n");
			// Query* parse = root->parse;
			// const List *rtable = parse->rtable;
			// ListCell *lc;
			// foreach(lc, rtable){
			// 	RangeTblEntry *rte = (RangeTblEntry *) lfirst(lc);
			// 	Query* sq = rte->subquery;

			// }
			appendStringInfo(sub_query, "(SubQuery_%d)", subplan_id);
			break;
		}
		case T_FuncExpr:
		{
			const FuncExpr *e = (const FuncExpr *) expr;
        	char	   *funcname;
        	ListCell   *l;

        	funcname = get_func_name(e->funcid);
    		printf("%s(", ((funcname != NULL) ? funcname : "(invalid function)"));
        	foreach(l, e->args)
        	{
        	    get_expr(lfirst(l), root);
        	    if (lnext(e->args, l))
        	        printf(",");
        	}
        	printf(")");
			break;
		}
		default:
		{
			printf("unknown expr");
			break;
		}
	}
}

/*
 * get restrict clauses and append them to the subquery string.
 */
static void
get_restrictclauses(PlannerInfo *root, List *clauses)
{
    ListCell   *l;
	bool		first = true;
	char	   *prefix;
    foreach(l, clauses)
    {
		if (first){
			prefix = isWhereOrAnd ? " WHERE " : " AND ";
			appendStringInfoString(sub_query, prefix);
			isWhereOrAnd = false;
		}
			
        RestrictInfo *c = lfirst(l);
		appendStringInfoChar(sub_query, '(');
        get_expr((Node *) c->clause, root);
		appendStringInfoChar(sub_query, ')');
        if (lnext(clauses, l))
			appendStringInfoString(sub_query, " AND ");
		first = false;
    }
}


/*
 * Get the relations from relids for deparse and update the visit flag accordingly. 
 */
static void 
get_rels_for_deparse (PlannerInfo *root, Relids relids, bool visit){
	int			x;
	// char	    *rname;
    x = -1;
    while ((x = bms_next_member(relids, x)) >= 0)
    {
        if (x < root->simple_rel_array_size &&
            root->simple_rte_array[x]){
			RangeTblEntry *rte = root->simple_rte_array[x];
			DeparseTblRef *dtr = context->all_rels[x];
			dtr->visit = visit;
			if (!visit){
				dtr->rtindex = x;
				dtr->rtekind = rte->rtekind;
				if (rte->rtekind == RTE_RELATION){
					dtr->rname = get_rel_name(rte->relid);
					dtr->alias = rte->eref->aliasname;
				}
				// }else if (rte->rtekind == RTE_SUBQUERY){
				// }
			}
		}
        else
			elog(ERROR, "error relids");
    }
}


/*
 * Get the relations from relids and append them to the subquery string. 
 */
static void 
get_rels_from_dtr (PlannerInfo *root, Relids relids, bool comma){
	int			x;
	// char	    *rname;
    x = -1;
    while ((x = bms_next_member(relids, x)) >= 0)
    {
        if (x < root->simple_rel_array_size &&
            root->simple_rte_array[x]){
			DeparseTblRef *dtr = context->all_rels[x];
			if (dtr->visit) continue;
			dtr->visit = true;
			if (dtr->rtekind == RTE_RELATION){
				char *rname = dtr->rname;
				char *alias = dtr->alias; 
				if (!rel_first && comma)
					appendStringInfoString(sub_query, ", ");
				if (strcmp(rname, alias)==0)
					appendStringInfoString(sub_query, rname);
				else
					appendStringInfo(sub_query, "%s %s", rname, alias);
			}
			// }else if (dtr->rtekind == RTE_SUBQUERY){
				
			// }
		}
        else
			appendStringInfoString(sub_query, "error");
        rel_first = false;
    }
}

/*
 * Get the relations from relids and append them to the subquery string. (for single-relation SQL)
 */
static void 
get_relids (PlannerInfo *root, Relids relids){
	int			x;
    bool		first = true;
	// char	    *rname;
    x = -1;
    while ((x = bms_next_member(relids, x)) >= 0)
    {
        if (!first)
			appendStringInfoString(sub_query, ", ");
        if (x < root->simple_rel_array_size &&
            root->simple_rte_array[x]){
			RangeTblEntry *rte = root->simple_rte_array[x];
			
			if (rte->rtekind == RTE_RELATION){
				char *rname = get_rel_name(rte->relid);
				char *alias = rte->eref->aliasname;
				if (strcmp(rname, alias)==0)
					appendStringInfoString(sub_query, rname);
				else
					appendStringInfo(sub_query, "%s %s", rname, alias);
			}
			// }else if (rte->rtekind == RTE_SUBQUERY){
				
			// }
		}
        else
			appendStringInfoString(sub_query, "error");
        first = false;
    }
	
}

/*
 * Get parameterized ndv subquery. Format: SELECT COUNT(DISTINCT r2.key from r2;  
 * param_clauses are parameterized clauses
 * relids are the rel->relids
 */
static void
get_parameterized_ndv_sql(PlannerInfo *root, Relids relids, List *param_clauses){
	ListCell   *l;
    foreach(l, param_clauses)
	{
		RestrictInfo *c = lfirst(l);
		if (bms_is_subset(c->required_relids, relids))
			continue;
		appendStringInfoString(sub_query, " SELECT COUNT(DISTINCT ");	
		if (bms_is_subset(c->left_relids, relids)){ // right is outer
			// get right hand 
			// Expr       *ex = (Expr *) c->clause;
			OpExpr	   *op = (OpExpr *) c->clause;
			ListCell   *lc = list_tail(op->args);
			get_expr(lfirst(lc), root);
			appendStringInfoString(sub_query, ") FROM ");
			get_relids(root, c->right_relids);
		}
		else{                                      // left is outer
			// get left hand
			// Expr       *ex = (Expr *) c->clause;
			OpExpr	   *op = (OpExpr *) c->clause;
			ListCell   *lc = list_head(op->args);
			get_expr(lfirst(lc), root);
			appendStringInfoString(sub_query, ") FROM ");
			get_relids(root, c->left_relids);
		}
		appendStringInfoChar(sub_query, ';');
    }
}


/*
 * Get single-relation subquery. Format: SELECT COUNT(*) FROM r1 (WHERE xxx);
 */
void
get_single_rel (PlannerInfo *root, RelOptInfo *rel) {
	sub_query = makeStringInfo();
	appendStringInfoString(sub_query, "SELECT COUNT(*) FROM ");
	get_relids(root, rel->relids);
	isWhereOrAnd = true;
	get_restrictclauses(root, rel->baserestrictinfo);
	appendStringInfoChar(sub_query, ';');
}


/*
 * Get parameterized single-relation subquery. 
 * Format: 
 * SELECT COUNT(*) FROM r1 WHERE filter(r1); 
 * SELECT COUNT(DISTINCT r2.key from r2; 
 * /* SELECT COUNT(*) FROM r1 WHERE filter(r1) and r1.key = r2.key * /
 */
void
get_parameterized_baserel (PlannerInfo *root, RelOptInfo *rel, List *param_clauses) {
	get_single_rel(root, rel);
	if (list_length(param_clauses) == 0){
		return;
	}
	get_parameterized_ndv_sql(root, rel->relids, param_clauses);
	List *allclauses = list_concat_copy(param_clauses, rel->baserestrictinfo);
	appendStringInfoString(sub_query, " /* ");
	appendStringInfoString(sub_query, "SELECT COUNT(*) FROM ");
	get_relids(root, rel->relids);
	isWhereOrAnd = true;
	get_restrictclauses(root, allclauses);
	appendStringInfoChar(sub_query, ';');
	appendStringInfoString(sub_query, " */");
}



static void
append_join_clause_to_context(PlannerInfo *root, RelOptInfo *join_rel, JoinType jointype, List *clauses){
	List	   *joinquals = NIL;
    ListCell   *l, *g;
	foreach(l, clauses)
	{
		JoinClause  *joinclause = (JoinClause *) palloc (sizeof(JoinClause));
		RestrictInfo *rinfo = lfirst_node(RestrictInfo, l);

		if (join_rel != NIL && !bms_is_subset((rinfo)->required_relids, join_rel->relids)){
			// should be treated as a filter clause rather than a join clause at that outer join. 
			context->ppi_clauses = lappend(context->ppi_clauses, rinfo);
			
		}
		else{   /* get join info */
			joinclause->swap = false;
			joinclause->jointype = jointype;
			// joinclause->left_relids = outer_relids;
			// joinclause->right_relids = inner_relids;
			joinclause->left_relids = rinfo->left_relids;
			joinclause->right_relids = rinfo->right_relids;
			joinclause->join_clause = rinfo;
    		if (bms_is_subset(joinclause->left_relids, context->where_join_rels) || bms_is_subset(joinclause->right_relids, context->where_join_rels)){
				context->where_join_clauses = lappend(context->where_join_clauses, joinclause);
			}else{
				bool isOverlap = false;
				foreach(g, context->on_join_clauses){
					JoinClauseGroup* jg = (JoinClauseGroup *) lfirst(g);
					Relids all_relids = bms_union(joinclause->left_relids, joinclause->right_relids);
					if(bms_overlap(joinclause->left_relids, jg->relids)){
						jg->relids = bms_join(jg->relids, all_relids);
						jg = lappend(jg->join_clauses, joinclause);
						isOverlap = true;
					}else if(bms_overlap(joinclause->right_relids, jg->relids)){
						jg->relids = bms_join(jg->relids, all_relids);
						joinclause->swap = true;
						jg = lappend(jg->join_clauses, joinclause);
						isOverlap = true;
					}
				}
				if (!isOverlap){
					JoinClauseGroup  *jg = (JoinClauseGroup *) palloc (sizeof(JoinClauseGroup));
					jg->relids = bms_union(joinclause->left_relids, joinclause->right_relids);
					jg->join_clauses = NIL;
					jg->join_clauses = lappend(jg->join_clauses, joinclause);
					context->on_join_clauses = lappend(context->on_join_clauses, jg);
				}
			}
		}
	}
}



/*
 * Get join restrict clauses from "ON" clause and append them to the subquery string.
 */
static void
get_on_join_restrictclauses(PlannerInfo *root, JoinClauseGroup* jg){
	ListCell* l;
	// foreach(l, jg->join_clauses){
	// 	appendStringInfoChar(sub_query, '(');
	// }
	bool first = true;
	char       *opname;
	foreach(l, jg->join_clauses){
		JoinClause *joinclause = (JoinClause *) lfirst(l);
		JoinType jointype = joinclause->jointype;
		RestrictInfo* rinfo = joinclause->join_clause;
		bool swap = joinclause->swap;

		if (first)  /* get left rel name */
    		get_rels_from_dtr(root, joinclause->left_relids, true);
		
		/* get join type name */
    	switch (jointype){
    	    case JOIN_INNER:
    	        opname = "INNER";
    	        break;
    	    case JOIN_LEFT:
    	        opname = "LEFT";
				if (swap)
					opname = "RIGHT";
    	        break;
    	    case JOIN_RIGHT:
    	        opname = "RIGHT";
				if (swap)
					opname = "LEFT";
    	        break;
    	    case JOIN_FULL:
    	        opname = "FULL";
    	        break;
    	    case JOIN_SEMI:
    	        opname = "SEMI";
    	        break;
    	    case JOIN_ANTI:
    	        opname = "ANTI";
    	        break;
    	    default:
    	        printf("unsupported join type %d\n", jointype);
    	        break;
    	}
    	appendStringInfo(sub_query, " %s JOIN ", opname);
    	/* get right rel name */
		if (swap)
    		get_rels_from_dtr(root, joinclause->left_relids, false);
		else
			get_rels_from_dtr(root, joinclause->right_relids, false);

    	appendStringInfoString(sub_query, " ON ");
    	/* get join expr*/
    	get_expr((Node *) rinfo->clause, root);
		// appendStringInfoChar(sub_query, ')');

		first = false;
	}
    
}

/*
 * Generate the subquery for a given path.
 */
static void
get_path(PlannerInfo *root, RelOptInfo *rel, Path *path)
{
	bool		join = false;
	Path	   *subpath = NULL;
	switch (nodeTag(path))
	{
		case T_NestPath:
			join = true;
			break;
		case T_MergePath:
			join = true;
			break;
		case T_HashPath:
			join = true;
			break;
		case T_MaterialPath:
			subpath = ((MaterialPath *) path)->subpath;
			break;
		case T_GatherPath:
			subpath = ((GatherPath *) path)->subpath;
			break;
		case T_GatherMergePath:
			subpath = ((GatherMergePath *) path)->subpath;
			break;
		default:
			break;
	}

	if (path->param_info && path->param_info->ppi_clauses)
	{
		append_join_clause_to_context(root, rel, JOIN_INNER, path->param_info->ppi_clauses);
	}

	if (join)
	{
		JoinPath   *jp = (JoinPath *) path;
		if (jp->joinrestrictinfo){
			// get_restrictclauses(root, jp->joinrestrictinfo);
			// appendStringInfoString(sub_query, ", ");
			append_join_clause_to_context(root, rel, jp->jointype, jp->joinrestrictinfo);
		}
		// else if (jp->innerjoinpath && jp->innerjoinpath->param_info && jp->innerjoinpath->param_info->ppi_clauses){
		// 	// appendStringInfoString(sub_query, ", ");
		// 	append_join_clause_to_context(root, rel, jp->jointype, jp->innerjoinpath->param_info->ppi_clauses);
		// }
		// else if (jp->outerjoinpath && jp->outerjoinpath->param_info && jp->outerjoinpath->param_info->ppi_clauses){
		// 	// appendStringInfoString(sub_query, ", ");
		// 	append_join_clause_to_context(root, rel, jp->jointype, jp->outerjoinpath->param_info->ppi_clauses);
		// }
		get_path(root, rel, jp->outerjoinpath);
		get_path(root, rel, jp->innerjoinpath);
	}
	if (subpath)
		get_path(root, rel, subpath);
}


/*
 * Select a physical path from the logical relation rel. 
 */
static void
get_path_from_rel (PlannerInfo *root, RelOptInfo *rel){
	ListCell   *lc;
	foreach(lc, rel->pathlist){
		Path	   *path = (Path *) lfirst(lc);
		if (path->pathtype == T_MergeJoin){
			get_path(root, rel, path);
			return;
		}
	}
	if (rel->cheapest_total_path)
		get_path(root, rel, rel->cheapest_total_path);
}

/*
 * Get the restrict clauses of the relation.
 */

static void 
get_base_restrictclauses (PlannerInfo *root, Relids relids){
	int			x;
	// char	    *rname;
    x = -1;
    while ((x = bms_next_member(relids, x)) >= 0)
    {
        if (x < root->simple_rel_array_size &&
            root->simple_rel_array[x]){
			get_restrictclauses(root, root->simple_rel_array[x]->baserestrictinfo);
		}
        else
			appendStringInfoString(sub_query, "error");
    }
	
}


/*
 * Get the join restrict clauses.
 */
static void
get_join_info(PlannerInfo *root){
	ListCell   *l;
	JoinClauseGroup *group;
	JoinClause *whereclause;
	bool first = true;
	foreach(l, context->on_join_clauses){
		group = (JoinClauseGroup *) lfirst(l);
		if (!first)
			appendStringInfoString(sub_query, ", ");
		get_on_join_restrictclauses(root, group);
		first = false;
	}
	List *clauses = NIL;
	list_sort(context->where_join_clauses, joinclause_relation_order_compare);
	foreach(l, context->where_join_clauses){
		whereclause = (JoinClause *) lfirst(l);
		clauses = lappend(clauses, whereclause->join_clause);
	}
	first = true;
	for(int i = 0; i < root->simple_rel_array_size; i++){
		if (context->all_rels[i]->rtindex == -1)
			continue;
		else{
			if (!context->all_rels[i]->visit){
				if (context->all_rels[i]->rtekind == RTE_RELATION){
					char *rname = context->all_rels[i]->rname;
					char *alias = context->all_rels[i]->alias;
					if (!first || (first && context->on_join_clauses))
						appendStringInfoString(sub_query, ", ");
					if (strcmp(rname, alias)==0)
						appendStringInfoString(sub_query, rname);
					else
						appendStringInfo(sub_query, "%s %s", rname, alias);
				}
				first = false;
			}
		}
	}
	
	get_restrictclauses(root, clauses);

}

/*
 * Create and initialize the DeparseTblRef object
 */
static DeparseTblRef **
makeDeparseTblRef(int num){
	DeparseTblRef ** all_rels = (DeparseTblRef **) palloc (num * sizeof(DeparseTblRef *));
	for (int i = 0; i < num; i++){
		all_rels[i] = (DeparseTblRef *) palloc (sizeof(DeparseTblRef));
		all_rels[i]->rtindex = -1;
		all_rels[i]->visit = false;
		all_rels[i]->rname = "";
		all_rels[i]->alias = "";
	}
	return all_rels;
}

/*
 * Get relations from root->parse->jointree
 */
static Relids
get_relids_only_in_rangetbl(Node *jtnode)
{
	Relids		result = NULL;

	if (jtnode == NULL)
		return result;
	if (IsA(jtnode, RangeTblRef))
	{
		int			varno = ((RangeTblRef *) jtnode)->rtindex;

		result = bms_make_singleton(varno);
	}
	else if (IsA(jtnode, FromExpr))
	{
		FromExpr   *f = (FromExpr *) jtnode;
		ListCell   *l;

		foreach(l, f->fromlist)
		{
			result = bms_join(result,
							  get_relids_only_in_rangetbl(lfirst(l)));
		}
	}
	return result;
}

/*
 * Get multi-relation subquery. Extract infomation from " select 、from、 where" 
 */

void
get_join_rel (PlannerInfo *root, 
					RelOptInfo *join_rel,
					RelOptInfo *outer_rel,
					RelOptInfo *inner_rel,
					SpecialJoinInfo *sjinfo,
					List *restrictlist_in) {
	rel_first = true;
	context = (DeparseCxt *) palloc (sizeof(DeparseCxt));
	context->all_rels = makeDeparseTblRef(root->simple_rel_array_size);
	context->where_join_clauses = NIL;
	context->on_join_clauses = NIL;
	context->ppi_clauses = NIL;
	sub_query = makeStringInfo();
	appendStringInfoString(sub_query, "SELECT COUNT(*) FROM ");
	get_rels_for_deparse(root, join_rel->relids, false);
	context->where_join_rels = get_relids_only_in_rangetbl((Node *)root->parse->jointree);
	JoinType	jointype = sjinfo->jointype;
	get_path_from_rel(root, outer_rel);
	get_path_from_rel(root, inner_rel);
	append_join_clause_to_context(root, join_rel, jointype, restrictlist_in);
	isWhereOrAnd = true;
	get_join_info(root);
	get_base_restrictclauses(root, join_rel->relids);
	appendStringInfoChar(sub_query, ';');
}

void 
get_parameterized_join_rel(PlannerInfo *root, 
					RelOptInfo *join_rel,
					Path *outer_path,
					Path *inner_path,
					SpecialJoinInfo *sjinfo,
					List *restrictlist_in)
{
	rel_first = true;
	context = (DeparseCxt *) palloc (sizeof(DeparseCxt));
	context->all_rels = makeDeparseTblRef(root->simple_rel_array_size);
	context->where_join_clauses = NIL;
	context->on_join_clauses = NIL;
	context->ppi_clauses = NIL;
	sub_query = makeStringInfo();
	appendStringInfoString(sub_query, "SELECT COUNT(*) FROM ");
	get_rels_for_deparse(root, join_rel->relids, false);
	context->where_join_rels = get_relids_only_in_rangetbl((Node *)root->parse->jointree);
	JoinType	jointype = sjinfo->jointype;
	get_path(root, join_rel, outer_path);
	get_path(root, join_rel, inner_path);
	append_join_clause_to_context(root, join_rel, jointype, restrictlist_in);
	isWhereOrAnd = true;
	get_join_info(root);
	get_base_restrictclauses(root, join_rel->relids);
	appendStringInfoChar(sub_query, ';');

	// for parameterized path
	get_parameterized_ndv_sql(root, join_rel->relids, context->ppi_clauses);

	if(list_length(context->ppi_clauses) != 0){
		appendStringInfoString(sub_query, " /* ");
		appendStringInfoString(sub_query, "SELECT COUNT(*) FROM ");
		isWhereOrAnd = true;
		get_join_info(root);
		get_restrictclauses(root, context->ppi_clauses);
		get_base_restrictclauses(root, join_rel->relids);
		appendStringInfoChar(sub_query, ';');
		appendStringInfoString(sub_query, " */");
	}
}
