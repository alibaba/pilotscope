from PilotConfig import PilotConfig


class SchedulerFactory:

    @staticmethod
    def get_pilot_scheduler(config: PilotConfig):
        from PilotScheduler import PilotScheduler
        return PilotScheduler(config)
