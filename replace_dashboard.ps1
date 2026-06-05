$filePath = "lib/screens/coach_dashboard.dart"
$content = [System.IO.File]::ReadAllText($filePath, [System.Text.Encoding]::UTF8).Replace("`r`n", "`n")

# 1. Target and replacement for todaySchedule in alarms activation
$targetAlarms = @'
                    final todaySchedule = _rotations
                        .where((e) =>
                            e.coachId == widget.currentUser.id &&
                            e.day == _getCurrentDayName())
                        .toList();
'@.Replace("`r`n", "`n")

$replacementAlarms = @'
                    final todaySchedule = _rotations.where((e) {
                      final isDay = e.day == _getCurrentDayName();
                      final isMainCoach = e.coachId == widget.currentUser.id;
                      final isAdditional = e.additionalCoaches?.contains(widget.currentUser.id) == true;
                      return isDay && (isMainCoach || isAdditional);
                    }).toList();
'@.Replace("`r`n", "`n")

# 2. Target and replacement for myBlocks in _buildRotationMatrix
$targetMatrix = @'
    final myBlocks = _rotations
        .where((e) => e.coachId == currentUser.id && e.day == dayName)
        .toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
'@.Replace("`r`n", "`n")

$replacementMatrix = @'
    final myBlocks = _rotations.where((e) {
      final isMainCoach = e.coachId == currentUser.id;
      final isAdditional = e.additionalCoaches?.contains(currentUser.id) == true;
      return (isMainCoach || isAdditional) && e.day == dayName;
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
'@.Replace("`r`n", "`n")

# 3. Target and replacement for todayRotations in _updateCurrentRotation
$targetUpdate = @'
  void _updateCurrentRotation() {
    final now = DateTime.now();
    final todayName = _getCurrentDayName();

    final todayRotations = _rotations.where((r) => r.day == todayName).toList();
'@.Replace("`r`n", "`n")

$replacementUpdate = @'
  void _updateCurrentRotation() {
    final now = DateTime.now();
    final todayName = _getCurrentDayName();
    final cid = currentUser.id;

    final todayRotations = _rotations.where((r) {
      final isDay = r.day == todayName;
      final isMainCoach = r.coachId == cid;
      final isAdditional = r.additionalCoaches?.contains(cid) == true;
      return isDay && (isMainCoach || isAdditional);
    }).toList();
'@.Replace("`r`n", "`n")

# Verify matches
$ok = $true
if (-not $content.Contains($targetAlarms)) { Write-Error "Target Alarms not found"; $ok = $false }
if (-not $content.Contains($targetMatrix)) { Write-Error "Target Matrix not found"; $ok = $false }
if (-not $content.Contains($targetUpdate)) { Write-Error "Target Update not found"; $ok = $false }

if ($ok) {
    $content = $content.Replace($targetAlarms, $replacementAlarms)
    $content = $content.Replace($targetMatrix, $replacementMatrix)
    $content = $content.Replace($targetUpdate, $replacementUpdate)
    [System.IO.File]::WriteAllText($filePath, $content.Replace("`n", "`r`n"), [System.Text.Encoding]::UTF8)
    Write-Host "SUCCESS: Replacement applied successfully to $filePath."
} else {
    Write-Error "Replacement aborted due to missing targets."
}
