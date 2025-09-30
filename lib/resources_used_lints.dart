import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'lint_rules/consulted_format_lint.dart';
import 'lint_rules/ai_prompt_format_lint.dart';
import 'lint_rules/ai_response_format_lint.dart';
import 'lint_rules/ai_other_format_lint.dart';
import 'lint_rules/reflection_format_lint.dart';
import 'lint_rules/ai_prompt_response_pair_lint.dart';
import 'lint_rules/reflection_required_lint.dart';

// Entrypoint of plugin
PluginBase createPlugin() => _ResourcesUsedLints();

// The class listing all the [LintRule]s and [Assist]s defined by our plugin
class _ResourcesUsedLints extends PluginBase {
  // Lint rules
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const ConsultedFormatLint(),
        const AiPromptFormatLint(),
        const AiResponseFormatLint(),
        const AiOtherFormatLint(),
        const ReflectionFormatLint(),
        const AiPromptResponsePairLint(),
        const ReflectionRequiredLint(),
      ];

  // Assists
  @override
  List<Assist> getAssists() => [];
}
