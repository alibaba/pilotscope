

def is_valid_conf_10knobs(conf, knobs_dict, check_cost_order=True):
    # Validate knob values
    for k, v in conf.items():
        d = knobs_dict[k]

        if 'choices' in d:
            # Validate that value is among choices
            if v not in d['choices']:
                print(f'{k}: {v} not in {d["choices"]}')
                return False
            continue

        #v = v_type(v[:-len(suffix)])
        min_v, max_v = d['min'], d['max']
        if not (min_v <= v <= max_v):
            print(f'{k}: {v} is not between {min_v} and {max_v}')
            return False

    return True

def finalize_conf(conf, knobs_dict, n_decimals=2):
    new_conf = { }
    for k, v in conf.items():
        if k not in knobs_dict:
            raise ValueError(f'Invalid knob value: "{k}"')
        d = knobs_dict[k]

        # Truncate decimals
        if d['type'] == 'real':
            v = round(v, n_decimals)

        new_conf[k] = v

    return new_conf

def unfinalize_conf(conf, knobs_dict):
    new_conf = { }
    for k, v in conf.items():
        if k not in knobs_dict:
            raise ValueError(f'Invalid knob value: "{k}"')
        d = knobs_dict[k]

        if d['type'] == 'integer':
            v = int(v)
        elif d['type'] == 'real':
            v = float(v)

        new_conf[k] = v

    return new_conf
