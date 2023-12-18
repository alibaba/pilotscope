from threading import Thread

from pilotscope.Common.Util import pilotscope_exit


class ValueThread(Thread):

    def __init__(self, group=None, target=None, name=None, args=(), kwargs=None, *, daemon=True):
        super().__init__(group, target, name, args, kwargs, daemon=daemon)
        self.result = None

    def run(self):
        if self._target is not None:
            try:
                self.result = self._target(*self._args, **self._kwargs)
            except Exception as e:
                print(e)
                raise e

    def join(self, timeout=None):
        super().join(timeout=timeout)
        return self.result
