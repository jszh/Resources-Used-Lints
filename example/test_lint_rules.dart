// Test file to demonstrate the lint rules

// ============================================================================
// VALID EXAMPLES (should not trigger any lints)
// ============================================================================

// Example 1: Complete CONSULTED sequence
// CONSULTED(https://dart.dev/guides): Learned about Dart language features
// REFLECTION: This helped me understand null safety and async programming

// Example 2: Complete AI interaction sequence
// AI_PROMPT(ChatGPT): Please help me write a function to calculate factorial
// AI_RESPONSE(ChatGPT): Here's a recursive function for factorial calculation
// REFLECTION: The AI response was helpful but I had to modify the base case handling

// Example 3: AI_OTHER usage
// AI_OTHER(GitHub Copilot): Used to refactor the existing code for better readability
// REFLECTION: The refactored code is much cleaner and easier to understand

// ============================================================================
// INVALID EXAMPLES (should trigger lints)
// ============================================================================

// Format violations:
// CONSULTED: Missing URL and parentheses
// CONSULTED(https://example.com) Missing colon and explanation
// AI_PROMPT: Missing tool name in parentheses
// AI_PROMPT() Missing tool name
// AI_PROMPT(ChatGPT) Missing colon and prompt text
// AI_RESPONSE: Missing tool name format
// AI_RESPONSE(GPT-4) Missing colon and content
// AI_OTHER: Missing proper format
// AI_OTHER(Copilot) Missing colon
// REFLECTION Missing colon entirely

// Relationship violations:

// Missing REFLECTION after CONSULTED
// CONSULTED(https://stackoverflow.com/questions/12345): Found sorting algorithm help

// Missing REFLECTION after AI_PROMPT (also missing AI_RESPONSE)
// AI_PROMPT(ChatGPT): How do I implement a binary tree?

// Missing AI_RESPONSE after AI_PROMPT
// AI_PROMPT(Claude): Explain async/await in Dart
// REFLECTION: I asked about async but didn't document the response

// Mismatched tool names in AI_PROMPT/AI_RESPONSE pair
// AI_PROMPT(ChatGPT): Write a hash function
// AI_RESPONSE(Claude): Here's a simple hash implementation
// REFLECTION: Got response from different tool than I asked

// Missing REFLECTION after AI_OTHER
// AI_OTHER(GitHub Copilot): Used for autocomplete suggestions

// Missing REFLECTION after AI_RESPONSE
// AI_PROMPT(GPT-4): Create a sorting function
// AI_RESPONSE(GPT-4): Here's a quicksort implementation

class TestClass {
  void testMethod() {
    // Method implementation
    print('Hello, World!');
  }
}
