abstract class CollectorEvent {}

class CollectorStart extends CollectorEvent {}

class CollectorStop extends CollectorEvent {}

class CollectorCollectNow extends CollectorEvent {}
