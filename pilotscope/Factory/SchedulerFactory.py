from pilotscope.PilotConfig import PilotConfig


class SchedulerFactory:

    @staticmethod
    def create_scheduler(config: PilotConfig):
        from pilotscope.PilotScheduler import PilotScheduler
        return PilotScheduler(config)
