import 'package:fuel_consumption/src/data/app_repository.dart';
import 'package:fuel_consumption/src/domain/models.dart';
import 'package:uuid/uuid.dart';

class VehicleDraft {
  const VehicleDraft({
    required this.name,
    required this.type,
    required this.initialOdometerKm,
    required this.model,
  });

  final String name;
  final VehicleType type;
  final double initialOdometerKm;
  final String model;
}

class VehicleCommandService {
  VehicleCommandService({required AppRepository repository, Uuid? uuid})
    : _repository = repository,
      _uuid = uuid ?? const Uuid();

  final AppRepository _repository;
  final Uuid _uuid;

  Future<void> createVehicle(VehicleDraft draft) {
    return _repository.saveVehicle(
      Vehicle(
        id: _uuid.v4(),
        name: draft.name,
        type: draft.type,
        initialOdometerKm: draft.initialOdometerKm,
        model: draft.model,
        isDefault: true,
      ),
    );
  }
}
