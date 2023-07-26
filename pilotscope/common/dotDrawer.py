from copy import copy

from common.Util import json_str_to_json_obj


class DotDrawer:
    def __init__(self) -> None:
        super().__init__()
        self.nodes = {}
        self.edge = {}

    def add_node(self, node_id, label):
        self.nodes[node_id] = label

    def add_edge(self, from_id: str, to_id: str, label):
        key = (from_id, to_id)
        self.edge[key] = label

    def get_dot_str(self):
        res = "digraph { \n rankdir=Tb \n"

        # add node
        for node_id, node_label in self.nodes.items():
            res += "\"{}\" [label=\"{}\"  ]\n".format(node_id, node_label)

        # add edge
        for ids, edge_label in self.edge.items():
            res += "\"{}\"->\"{}\"[label= \" {} \"] \n".format(ids[0], ids[1], edge_label)

        res += "\n }"
        return res


class PlanDotDrawer:
    dot_node_id = 0

    def __init__(self) -> None:
        super().__init__()

    @classmethod
    def get_plan_dot_str(cls, plan):
        if isinstance(plan, str):
            plan = json_str_to_json_obj(plan)
        dot_drawer = DotDrawer()

        def fill(plan_node):
            node_id = plan_node["dot_id"]
            node_label = cls._get_node_label(plan_node)
            dot_drawer.add_node(node_id, node_label)
            children = cls._get_child(plan_node)

            for child in children:
                edge_label = cls._get_edge_info(plan_node, child)
                dot_drawer.add_edge(child["dot_id"], node_id, edge_label)
                fill(child)

        plan = copy(plan)["Plan"]
        cls._add_unique_id(plan)
        fill(plan)
        return dot_drawer.get_dot_str()

    @classmethod
    def _get_node_label(cls, plan_node):
        SCAN_TYPES = ["Seq Scan", "Index Scan", "Index Only Scan", 'Bitmap Heap Scan']
        JOIN_TYPES = ["Nested Loop", "Hash Join", "Merge Join"]
        OTHER_TYPES = ['Bitmap Index Scan']

        node_type = plan_node["Node Type"]

        label = "{}".format(node_type)
        if node_type in SCAN_TYPES:
            table = plan_node["Relation Name"]
            label += ", table is {}".format(table)

        return label

    @classmethod
    def _add_unique_id(cls, plan):
        def recurse(plan_node):
            plan_node["dot_id"] = cls.dot_node_id
            children = cls._get_child(plan_node)
            for child in children:
                cls.dot_node_id += 1
                recurse(child)

        recurse(plan)
        cls.dot_node_id = 0
        return plan

    @classmethod
    def _get_child(cls, plan_node):
        child = []
        if "Plans" in plan_node:
            child += plan_node["Plans"]
        return child

    @classmethod
    def _get_edge_info(cls, parent, child):
        return ""
