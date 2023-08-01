from pilotscope.PilotConfig import PilotConfig


class SchedulerFactory:

    @staticmethod
    def get_pilot_scheduler(config: PilotConfig):
        from pilotscope.PilotScheduler import PilotScheduler
        return PilotScheduler(config)
