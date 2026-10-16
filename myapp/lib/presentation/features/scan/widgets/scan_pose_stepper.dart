import 'package:flutter/material.dart';
import 'package:saaf/core/l10n/app_localizations.dart';
import 'package:saaf/core/theme/saaf_tokens_extension.dart';
import 'package:saaf/domain/entities/face_pose.dart';
import 'package:saaf/presentation/features/scan/widgets/pose_text.dart';
import 'package:saaf/presentation/widgets/common/saaf_progress_bar.dart';

/// "Front · Left · Right": three segments showing which photo is being taken
/// and which are done. A finished step can be tapped to look at it again.
class ScanPoseStepper extends StatelessWidget {
  const ScanPoseStepper({
    required this.current,
    required this.taken,
    required this.onSelect,
    super.key,
  });

  final FacePose current;
  final Set<FacePose> taken;
  final ValueChanged<FacePose> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    return Row(
      spacing: tokens.space.x8,
      children: [
        for (final pose in FacePose.values)
          Expanded(
            child: _Step(
              pose: pose,
              isCurrent: pose == current,
              isTaken: taken.contains(pose),
              onTap: () => onSelect(pose),
            ),
          ),
      ],
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.pose,
    required this.isCurrent,
    required this.isTaken,
    required this.onTap,
  });

  final FacePose pose;
  final bool isCurrent;
  final bool isTaken;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.saaf;
    final l10n = AppLocalizations.of(context);
    final name = pose.label(l10n);
    final spoken = l10n.scanStepSemantics(
      pose.number,
      FacePose.count,
      isTaken ? '$name, ${l10n.scanStepDone}' : name,
    );
    final progress = isTaken ? 1.0 : (isCurrent ? 0.5 : 0.0);

    return Semantics(
      button: isTaken,
      selected: isCurrent,
      label: spoken,
      excludeSemantics: true,
      onTap: isTaken ? onTap : null,
      child: InkWell(
        onTap: isTaken ? onTap : null,
        borderRadius: BorderRadius.circular(tokens.radius.r12),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: tokens.size.minTouchTarget),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: tokens.space.x6,
            children: [
              SaafProgressBar(value: progress, onInk: true),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: tokens.space.x4,
                children: [
                  if (isTaken)
                    Icon(
                      Icons.check,
                      size: tokens.size.iconChip,
                      color: tokens.sage,
                    ),
                  Flexible(
                    child: Text(
                      name,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(
                        color: isCurrent
                            ? context.colors.onSurface
                            : tokens.onInkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
