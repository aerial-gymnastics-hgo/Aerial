import 'package:flutter/material.dart';

/// Configuración de columnas para cada grupo.
class GroupColumnConfig {
  final String groupId;
  final String displayName;
  final int columns; // número de sub‑columnas (1 = sin sub‑grupo)
  final bool hasInternalRotation;
  final List<String>? subgroups; // N1, N2, etc.
  final List<String>? rotationLevels; // A1, A2, ...

  const GroupColumnConfig({
    required this.groupId,
    required this.displayName,
    this.columns = 1,
    this.hasInternalRotation = false,
    this.subgroups,
    this.rotationLevels,
  });
}

/// Representa una columna física en la tabla Excel.
class PhysicalColumn {
  final String groupId; // base, ej. "panditas"
  final String? subgroupId; // "N1" o null
  final String displayName; // texto que se muestra en el header

  const PhysicalColumn({
    required this.groupId,
    this.subgroupId,
    required this.displayName,
  });

  /// ID único usado para buscar slots: combina group + sub‑grupo.
  String get fullId => subgroupId != null ? '${groupId}_$subgroupId' : groupId;
}

/// Mapa de configuraciones de los grupos oficiales.
const Map<String, GroupColumnConfig> groupConfigurations = {
  'dragonas': GroupColumnConfig(
    groupId: 'dragonas',
    displayName: 'DRAGONAS',
  ),
  'leonas': GroupColumnConfig(
    groupId: 'leonas',
    displayName: 'LEONAS',
  ),
  'panteras': GroupColumnConfig(
    groupId: 'panteras',
    displayName: 'PANTERAS',
  ),
  'panditas': GroupColumnConfig(
    groupId: 'panditas',
    displayName: 'PANDITAS',
    columns: 2,
    subgroups: ['N1', 'N2'],
  ),
  'n3': GroupColumnConfig(
    groupId: 'n3',
    displayName: 'N3',
  ),
  'n4_n5': GroupColumnConfig(
    groupId: 'n4_n5',
    displayName: 'N4/N5',
    // Una sola columna: los slots no llevan subgroupId (N4 y N5 entrenan juntos)
  ),
  'tigresas': GroupColumnConfig(
    groupId: 'tigresas',
    displayName: 'TIGRESAS',
  ),
  'abejitas': GroupColumnConfig(
    groupId: 'abejitas',
    displayName: 'ABEJITAS',
    hasInternalRotation: true,
    rotationLevels: ['A1', 'A2', 'A3'],
  ),
  'mariposas': GroupColumnConfig(
    groupId: 'mariposas',
    displayName: 'MARIPOSAS',
    hasInternalRotation: true,
    rotationLevels: ['M1', 'M2', 'M3', 'M4'],
  ),
  'oruguitas': GroupColumnConfig(
    groupId: 'oruguitas',
    displayName: 'ORUGUITAS',
    hasInternalRotation: true,
    rotationLevels: ['M1', 'M2', 'M3', 'M4'],
  ),
  'conejas': GroupColumnConfig(
    groupId: 'conejas',
    displayName: 'CONEJAS',
  ),
  'halconas': GroupColumnConfig(
    groupId: 'halconas',
    displayName: 'HALCONAS',
  ),
  'linces': GroupColumnConfig(
    groupId: 'linces',
    displayName: 'LINCES',
  ),
  'baby_gym_a': GroupColumnConfig(
    groupId: 'baby_gym_a',
    displayName: 'BABY GYM A',
  ),
  'baby_gym_b': GroupColumnConfig(
    groupId: 'baby_gym_b',
    displayName: 'BABY GYM B',
  ),
};
