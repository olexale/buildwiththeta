// Flutter imports:
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// Package imports:
import 'package:theta_models/theta_models.dart';
import 'package:theta_open_widgets/src/elements/builders/override_executer.dart';
import 'package:theta_open_widgets/src/elements/builders/text_style_builder.dart';

/// Returns a [Text] widget with all the properties
class TextBuilder extends StatelessWidget {
  /// Constructor
  const TextBuilder({
    super.key,
    required this.nodeState,
    required this.textStyle,
    required this.value,
    this.maxLines,
  });

  final WidgetState nodeState;
  final FTextTypeInput value;
  final FTextTypeInput? maxLines;
  final FTextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final TreeState state = context.watch<TreeState>();
    final model = state.textStyles.firstWhereOrNull(
        (element) => element.name == textStyle.textStyleModel);
    final maxLinesValue = maxLines?.get(
      loop: nodeState.loop,
      deviceType: state.deviceType,
      forPlay: state.forPlay,
      context: context,
    );
    var intValue = int.tryParse(maxLinesValue ?? '');
    if (intValue != null && intValue <= 0) {
      intValue = 1;
    }
    final data = const NodeOverrideExecuter().executeText(
        context,
        nodeState,
        value.get(
            loop: nodeState.loop,
            deviceType: state.deviceType,
            forPlay: state.forPlay,
            context: context));
    return Text(
      data,
      style: TetaTextStyles.get(
        nodeState: nodeState,
        state: state,
        context: context,
        model: model,
        forPlay: state.forPlay,
        fill: textStyle.fill,
        fontFamily: textStyle.fontFamily,
        fontSize: textStyle.fontSize,
        fontWeight: textStyle.fontWeight,
        textDecoration: textStyle.textDecoration,
        fontStyle: textStyle.fontStyle,
      ),
      textAlign: textStyle.textAlign.value,
      maxLines: intValue,
      textDirection: textStyle.textDirection.value,
    );
  }
}
