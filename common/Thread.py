from threading import Thread


class ValueThread(Thread):

    def __init__(self, group=None, target=None, name=None, args=(), kwargs=None, *, daemon=None):
        super().__init__(group, target, name, args, kwargs, daemon=daemon)
        self.result = None

    def run(self):
        if self._target is not None:
            self.result = self._target(*self._args, **self._kwargs)

    def join(self, timeout=None):
        super().join(timeout=timeout)
        return self.result
