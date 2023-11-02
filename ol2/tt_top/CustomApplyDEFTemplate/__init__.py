import os
from openlane.steps import Step
from openlane.steps.odb import ApplyDEFTemplate
from .__version__ import __version__
from typing import List, Optional
from openlane.config import Variable


@Step.factory.register()
class CustomApplyDEFTemplate(ApplyDEFTemplate):
    """
    This is a custom step that overrides the ApplyDEFTemplate step, to a custom apply_def_template.py
    This custom step is for openframe to generate the correct power pins
    """

    id = "CustomApplyDEFTemplate.CustomApplyDEFTemplate"
    name = "Custom Apply DEF Template"

    config_vars = ApplyDEFTemplate.config_vars + [
        Variable(
            "FP_TEMPLATE_PINS",
            Optional[List[str]],
            "Adds Pins that will be forced into the design from the def template",
        ),
    ]

    def get_script_path(self):
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), "apply_def_template.py")

    def get_command(self) -> List[str]:
        template_args = []
        for pin in self.config["FP_TEMPLATE_PINS"]:
            template_args.append("-t")
            template_args.append(pin)
        template_args.append("-d")
        template_args.append(self.config["FP_DEF_TEMPLATE"])
        return super().get_command() + template_args