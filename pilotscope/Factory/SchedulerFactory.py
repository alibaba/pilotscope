from pilotscope.PilotConfig import PilotConfig
from pilotscope.PilotScheduler import PilotScheduler


class SchedulerFactory:

    @staticmethod
    def create_scheduler(config: PilotConfig):
        """
        Create a scheduler instance based on the config.

        :param config: The config of PilotScope.
        """
        return PilotScheduler(config)
