import json

TRIGGER_KEY_CODE = 'd'
TRIGGER_MODIFIERS = ['command', 'control']
TRIGGER_CLEAR_TIME = 1000
TRIGGER_VARIABLE = "yabai_mod"

BASE_MANIPULATOR = {
}

root_config = {
    "title": "Yabai Things",
    "rules": []
}

trigger_manipulator = {
    "type": "basic",
    "parameters": {
        "basic.to_delayed_action_delay_milliseconds": TRIGGER_CLEAR_TIME
    },
    "from": {
        "key_code": TRIGGER_KEY_CODE,
        "modifiers": {
            "mandatory": TRIGGER_MODIFIERS,
        },
    },
    "to": [
        {
            "set_variable": {
                "name": TRIGGER_VARIABLE,
                "value": 1
            }
        }
    ],
    "to_delayed_action": {
        "to_if_invoked": [
            {
                "set_variable": {
                    "name": TRIGGER_VARIABLE,
                    "value": 0
                }
            }
        ]
    },
}

rules = [
    {
        "description": "Yabai Trigger",
        "manipulators": [trigger_manipulator]
    }
]

command_manipulators = []

key_map = {
    # Make float
    'x': '@yabai@/bin/yabai -m window --toggle float',
    # Make fullscreen
    'f': '@yabai@/bin/yabai -m window --toggle zoom-fullscreen',

    # Move windows
    'h': '@yabai@/bin/yabai -m window --warp west',
    'j': '@yabai@/bin/yabai -m window --warp south',
    'k': '@yabai@/bin/yabai -m window --warp north',
    'l': '@yabai@/bin/yabai -m window --warp east',

    # Swap windows
    'shift h': '@yabai@/bin/yabai -m window --swap west',
    'shift j': '@yabai@/bin/yabai -m window --swap north',
    'shift k': '@yabai@/bin/yabai -m window --swap south',
    'shift l': '@yabai@/bin/yabai -m window --swap east',

    # Rotate tree
    'r': '@yabai@/bin/yabai -m space --rotate 90',
    'e': '@yabai@/bin/yabai -m space --mirror y-axis',
    'q': '@yabai@/bin/yabai -m space --mirror x-axis',

    # Change split size
    'control j': '@yabai@/bin/yabai -m window --ratio rel:-0.05',
    'control k': '@yabai@/bin/yabai -m window --ratio rel:0.05',
    '=': '@yabai@/bin/yabai -m window --ratio abs:0.5',


    # Restart yabai
    'control p': '@yabai@/bin/yabai --restart-service',
}

for key_spec, command in key_map.items():
    key_spec = key_spec.split(' ')
    key = key_spec[-1]
    modifiers = key_spec[:-1]
    manipulator = {
        "type": "basic",
        "parameters": {
            "basic.to_delayed_action_delay_milliseconds": TRIGGER_CLEAR_TIME
        },
        "conditions": [
            {
                "type": "variable_if",
                "name": TRIGGER_VARIABLE,
                "value": 1
            }
        ],
        "to_delayed_action": {
            "to_if_invoked": [
                {
                    "set_variable": {
                        "name": TRIGGER_VARIABLE,
                        "value": 0
                    }
                }
            ]
        },
        "from": {
            "key_code": key
        },
        "to": [
            {
                "shell_command": command
            }
        ],
    }
    if len(modifiers) > 0:
        manipulator['from']['modifiers'] = {'mandatory': modifiers}
    command_manipulators.append(manipulator)

rules.append({
    "description": "Yabai Commands",
    "manipulators": command_manipulators,
})

print(json.dumps({
    'title': "Yabai Key Bindings",
    'rules': rules,
}))
