from Anchor.BaseAnchor.replaceAnchorHandler import ReplaceAnchorHandler


def is_number(value):
    try:
        value = float(value)
        return True
    except Exception as e:
        return False


def extract_anchor_handlers(handlers, is_fetch_anchor):
    from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
    target = FetchAnchorHandler if is_fetch_anchor else ReplaceAnchorHandler
    return list(filter(lambda anchor: isinstance(anchor, target), handlers))


def extract_table_data_from_anchor(fetch_anchors, data):
    from Anchor.BaseAnchor.FetchAnchorHandler import FetchAnchorHandler
    column_2_value = {}
    for anchor in fetch_anchors:
        if isinstance(anchor, FetchAnchorHandler):
            anchor.add_data_to_table(column_2_value, data)
        else:
            raise RuntimeError
    return column_2_value
