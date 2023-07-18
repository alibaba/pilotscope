from featurize import ALL_SPARK_TYPES


class SparkPlanCompress:
    def __init__(self, save_op_types=ALL_SPARK_TYPES) -> None:
        self.save_op_types = set(save_op_types)

    def compress(self, json):
        self.recurse_update_children(json)
        return json

    def recurse_update_children(self, node):
        children = self.get_children(node)
        new_children = []
        for child in children:
            self.recurse_update_children(child)
            if not self.is_valid_node(child):
                gran_children = self.get_children(child)
                if len(gran_children) > 1:
                    raise RuntimeError("exhibit to ignore the node that has two and more input")
                new_children.append(gran_children[0])
            else:
                new_children.append(child)
        if len(new_children) > 0:
            node["Plans"] = new_children

    def is_valid_node(self, node):
        node_type = node["class"]
        return node_type in self.save_op_types

    def get_children(self, node):
        if "Plans" in node:
            return node["Plans"]
        return []
