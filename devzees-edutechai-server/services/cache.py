"""
EduTechAI — Bounded In-Memory TTL/LRU Cache Utilities

Zero-dependency, process-local bounded caches backed by OrderedDict so
in-memory session and standing caches never grow unbounded without Redis.
"""

from __future__ import annotations

from collections import OrderedDict
import time
from typing import Generic, TypeVar

V = TypeVar("V")


class BoundedTTLCache(Generic[V]):
    """
    Bounded LRU + TTL dictionary-compatible cache.

    Supports both fixed TTL (e.g. standing cache) and sliding TTL
    (e.g. active session cache where reads refresh expiration).
    """

    def __init__(
        self,
        maxsize: int = 5000,
        ttl_seconds: float = 1800.0,
        sliding: bool = False,
    ) -> None:
        self.maxsize = max(1, maxsize)
        self.ttl_seconds = ttl_seconds
        self.sliding = sliding
        self._data: OrderedDict[str, tuple[float, V]] = OrderedDict()

    def _evict_expired(self, now: float) -> None:
        expired_keys = [k for k, (exp, _) in self._data.items() if now >= exp]
        for k in expired_keys:
            self._data.pop(k, None)

    def get(self, key: str, default: V | None = None) -> V | None:
        item = self._data.get(key)
        if item is None:
            return default
        now = time.monotonic()
        exp, val = item
        if now >= exp:
            self._data.pop(key, None)
            return default
        if self.sliding:
            self._data[key] = (now + self.ttl_seconds, val)
        self._data.move_to_end(key)
        return val

    def __getitem__(self, key: str) -> V:
        val = self.get(key)
        if val is None and key not in self:
            raise KeyError(key)
        return val  # type: ignore[return-value]

    def __setitem__(self, key: str, value: V) -> None:
        now = time.monotonic()
        if key in self._data:
            self._data[key] = (now + self.ttl_seconds, value)
            self._data.move_to_end(key)
            return

        if len(self._data) >= self.maxsize:
            self._evict_expired(now)
            while len(self._data) >= self.maxsize:
                self._data.popitem(last=False)

        self._data[key] = (now + self.ttl_seconds, value)

    def __contains__(self, key: object) -> bool:
        if not isinstance(key, str):
            return False
        item = self._data.get(key)
        if item is None:
            return False
        if time.monotonic() >= item[0]:
            self._data.pop(key, None)
            return False
        return True

    def pop(self, key: str, default: V | None = None) -> V | None:
        item = self._data.pop(key, None)
        if item is None:
            return default
        if time.monotonic() >= item[0]:
            return default
        return item[1]

    def clear(self) -> None:
        self._data.clear()

    def __len__(self) -> int:
        self._evict_expired(time.monotonic())
        return len(self._data)


class BoundedTTLSet:
    """Bounded LRU + TTL set-compatible cache (e.g. cancelled session IDs)."""

    def __init__(self, maxsize: int = 5000, ttl_seconds: float = 3600.0) -> None:
        self._cache: BoundedTTLCache[bool] = BoundedTTLCache(
            maxsize=maxsize,
            ttl_seconds=ttl_seconds,
            sliding=False,
        )

    def add(self, key: str) -> None:
        self._cache[key] = True

    def discard(self, key: str) -> None:
        self._cache.pop(key, None)

    def clear(self) -> None:
        self._cache.clear()

    def __contains__(self, key: object) -> bool:
        return key in self._cache

    def __len__(self) -> int:
        return len(self._cache)
