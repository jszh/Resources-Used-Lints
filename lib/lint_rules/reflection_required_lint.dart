import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/error/error.dart' hide LintCode;
import 'package:custom_lint_builder/custom_lint_builder.dart';
import 'dart:math' as math;

class ReflectionRequiredLint extends DartLintRule {
  // Only match properly formatted comments
  static final _consultedRegExp = RegExp(
      r'//\s*CONSULTED\((?=[^()]*\w)[^()\s](?:[^()]*[^()\s])?\):\s*.+',
      caseSensitive: false);
  static final _aiCommentRegExp = RegExp(
      r'//\s*AI_(PROMPT|RESPONSE|OTHER)\((?=[^()]*\w)[^()\s](?:[^()]*[^()\s])?\):\s*.+',
      caseSensitive: false);
  static final _reflectionRegExp =
      RegExp(r'//\s*REFLECTION:\s*.+', caseSensitive: false);

  const ReflectionRequiredLint() : super(code: _code);

  static const _code = LintCode(
      name: 'reflection_required',
      problemMessage:
          'CONSULTED and AI_* comments must be followed by REFLECTION',
      errorSeverity: DiagnosticSeverity.ERROR);

  @override
  void run(
    CustomLintResolver resolver,
    reporter,
    CustomLintContext context,
  ) {
    context.registry.addCompilationUnit((node) {
      _visitCompilationUnit(node, reporter);
    });
  }

  void _visitCompilationUnit(CompilationUnit node, reporter) {
    // Collect all comments from the compilation unit
    List<Token> allComments = [];
    Token? token = node.beginToken;

    while (token != null) {
      Token? comment = token.precedingComments;
      while (comment != null) {
        allComments.add(comment);
        comment = comment.next;
      }
      if (token == token.next) break;
      token = token.next;
    }

    // Process comments sequentially to find groups that need reflection
    List<Token> currentGroup = [];
    bool inMultiLineDeclaration = false;

    for (int i = 0; i < allComments.length; i++) {
      var comment = allComments[i];
      var content = comment.lexeme.trim();

      if (_consultedRegExp.hasMatch(content) ||
          _aiCommentRegExp.hasMatch(content)) {
        // This is a valid resource comment - add to current group
        currentGroup.add(comment);
        inMultiLineDeclaration = true;
      } else if (_reflectionRegExp.hasMatch(content)) {
        // Found a reflection - this satisfies the current group
        currentGroup.clear();
        inMultiLineDeclaration = false;
      } else if (inMultiLineDeclaration && _isCommentContinuation(content)) {
        // This is a continuation line of a multi-line declaration
        // Don't treat it as a separate comment that breaks the group
        continue;
      } else {
        // End of multi-line declaration (or other comment)
        if (inMultiLineDeclaration) {
          inMultiLineDeclaration = false;
        }

        // This is some other comment or blank line
        // If we have a group and this isn't blank, check if reflection follows
        if (currentGroup.isNotEmpty && !_isBlankComment(content)) {
          // Look ahead to see if there's a reflection coming up
          bool hasUpcomingReflection = _hasReflectionInRange(
              allComments, i, math.min(i + 20, allComments.length));

          if (!hasUpcomingReflection) {
            // No reflection found - report the group
            for (var groupComment in currentGroup) {
              reporter.atOffset(
                errorCode: _code,
                offset: groupComment.offset,
                length: groupComment.length,
              );
            }
          }
          currentGroup.clear();
        }
      }
    }

    // Handle any remaining group at the end
    if (currentGroup.isNotEmpty) {
      for (var groupComment in currentGroup) {
        reporter.atOffset(
          errorCode: _code,
          offset: groupComment.offset,
          length: groupComment.length,
        );
      }
    }
  }

  bool _hasReflectionInRange(List<Token> comments, int startIdx, int endIdx) {
    for (int i = startIdx; i < endIdx; i++) {
      var content = comments[i].lexeme.trim();
      if (_reflectionRegExp.hasMatch(content)) {
        return true;
      }
      // Stop looking if we hit another resource comment group
      if (_consultedRegExp.hasMatch(content) ||
          _aiCommentRegExp.hasMatch(content)) {
        break;
      }
    }
    return false;
  }

  bool _isBlankComment(String content) {
    // Consider a comment blank if it's just // with optional whitespace
    return RegExp(r'^//\s*$').hasMatch(content);
  }

  bool _isCommentContinuation(String content) {
    // A comment continuation is any comment line that doesn't start a new declaration
    // and isn't a reflection or blank line
    return content.startsWith('//') &&
        !_consultedRegExp.hasMatch(content) &&
        !_aiCommentRegExp.hasMatch(content) &&
        !_reflectionRegExp.hasMatch(content) &&
        !_isBlankComment(content);
  }
}
