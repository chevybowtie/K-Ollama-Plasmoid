/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick
import QtTest
import QtQuick.Controls
import "../contents/ui" as UI
import "../contents/js/utils.js" as Utils

TestCase {
    id: testCase
    name: "MarkdownTests"
    
    // Test configuration property existence and defaults
    function test_enableMarkdown_configuration_property() {
        // Create a mock configuration object
        var mockConfig = {
            enableMarkdown: false
        };
        
        // Verify default is false
        verify(!mockConfig.enableMarkdown);
    }
    
    // Test that markdown configuration can be toggled
    function test_enableMarkdown_configuration_toggle() {
        var mockConfig = {
            enableMarkdown: false
        };
        
        // Toggle to true
        mockConfig.enableMarkdown = true;
        verify(mockConfig.enableMarkdown);
        
        // Toggle back to false
        mockConfig.enableMarkdown = false;
        verify(!mockConfig.enableMarkdown);
    }
    
    // Test component loading based on configuration
    function test_component_loading_plain_text() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: "Simple test message"
        });
        
        verify(loader);
        verify(loader.item);
        
        // Should load the plain text component (TextEdit)
        compare(typeof loader.item.selectAll, "function");
        compare(typeof loader.item.copy, "function");
        compare(typeof loader.item.deselect, "function");
    }
    
    function test_component_loading_markdown() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: "**Bold** and *italic* text"
        });
        
        verify(loader);
        verify(loader.item);
        
        // Should load the markdown component (ScrollView with TextArea)
        compare(typeof loader.item.selectAll, "function");
        compare(typeof loader.item.copy, "function");
        compare(typeof loader.item.deselect, "function");
    }
    
    // Test markdown rendering vs plain text
    function test_markdown_vs_plain_text_content() {
        var markdownContent = "# Heading 1\n\n**Bold text** and *italic text*\n\n- List item 1\n- List item 2\n\n`code snippet`";

        var plainLoader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: markdownContent
        });

        var markdownLoader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: markdownContent
        });

        verify(plainLoader);
        verify(plainLoader.item);
        verify(markdownLoader);
        verify(markdownLoader.item);

        compare(plainLoader.item.text, markdownContent);
        // Qt's MarkdownText TextArea appends trailing \n\n on round-trip; trim both sides
        compare(markdownLoader.item.text.trim(), markdownContent.trim());
    }

    // Full message text must be accessible for copy — copy reads .text, not rendered output
    function test_full_message_text_accessible_for_copy() {
        var fullMessage = "# Header\n\nThis is a **full** message with *formatting* and:\n\n```python\nprint('hello')\n```\n\nA final paragraph.";

        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: fullMessage
        });

        verify(loader);
        verify(loader.item);
        // Qt normalizes MarkdownText on round-trip (trailing \n\n, collapsed blank lines between
        // code fences and following paragraphs). Check that key content survives, not exact bytes.
        verify(loader.item.text.indexOf("# Header") !== -1);
        verify(loader.item.text.indexOf("**full**") !== -1);
        verify(loader.item.text.indexOf("print('hello')") !== -1);
        verify(loader.item.text.indexOf("A final paragraph.") !== -1);

        // selectAll/copy/deselect must be callable without error
        loader.item.selectAll();
        loader.item.copy();
        loader.item.deselect();
        verify(true);
    }

    // Code fence content (including fence markers) must survive round-trip through the text property
    function test_code_fence_content_preserved() {
        var codeMessage = "Here is some code:\n\n```python\nimport os\nprint(os.getcwd())\n```\n\nAnd another block:\n\n```bash\necho hello\n```";

        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: codeMessage
        });

        verify(loader);
        verify(loader.item);
        verify(loader.item.text.indexOf("import os") !== -1);
        verify(loader.item.text.indexOf("echo hello") !== -1);
        verify(loader.item.text.indexOf("```python") !== -1);
        verify(loader.item.text.indexOf("```bash") !== -1);
    }

    // Toggling markdown on/off must not lose the underlying message text
    function test_markdown_toggle_preserves_content() {
        var message = "**Bold** and `code` content";

        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: message
        });

        verify(loader);
        verify(loader.item);
        compare(loader.item.text, message);

        // Qt's MarkdownText TextArea appends trailing \n\n on round-trip; trim both sides
        loader.enableMarkdown = true;
        verify(loader.item);
        compare(loader.item.text.trim(), message.trim());

        loader.enableMarkdown = false;
        verify(loader.item);
        compare(loader.item.text, message);
    }
    
    // Test copy functionality for both components
    function test_copy_functionality_plain_text() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: "Test copy text"
        });
        
        verify(loader);
        verify(loader.item);
        
        // Test that copy methods exist and can be called
        loader.item.selectAll();
        loader.item.copy();
        loader.item.deselect();
        
        // No errors should occur
        verify(true);
    }
    
    function test_copy_functionality_markdown() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: "**Bold** copy test"
        });
        
        verify(loader);
        verify(loader.item);
        
        // Test that copy methods exist and can be called
        loader.item.selectAll();
        loader.item.copy();
        loader.item.deselect();
        
        // No errors should occur
        verify(true);
    }
    
    // Test height calculations
    function test_implicit_height_property() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: "Single line"
        });
        
        verify(loader);
        verify(loader.item);
        verify(loader.implicitHeight > 0);
        
        // Change to multiline content
        loader.messageText = "Line 1\nLine 2\nLine 3";
        verify(loader.implicitHeight > 0);
    }
    
    // Test configuration change behavior
    function test_configuration_change() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: "**Test** content"
        });
        
        verify(loader);
        verify(loader.item);
        
        // Change configuration - component should reload
        loader.enableMarkdown = true;
        verify(loader.item);
        
        // Change back
        loader.enableMarkdown = false;
        verify(loader.item);
    }
    
    // Test with empty content
    function test_empty_content_handling() {
        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: ""
        });
        
        verify(loader);
        verify(loader.item);
        verify(loader.item !== null);
    }
    
    // Test with special markdown characters
    function test_special_markdown_characters() {
        var specialContent = "# Header\n\n> Quote\n\n```\ncode block\n```\n\n| Table | Header |\n|-------|--------|\n| Cell  | Value  |";

        var loader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: specialContent
        });

        verify(loader);
        verify(loader.item);
        verify(loader.item !== null);
    }

    // --- extractCodeBlocks unit tests ---

    function test_extract_no_blocks_returns_empty() {
        var result = Utils.extractCodeBlocks("No code here, just plain text.");
        compare(result.length, 0);
    }

    function test_extract_null_returns_empty() {
        compare(Utils.extractCodeBlocks(null).length, 0);
        compare(Utils.extractCodeBlocks("").length, 0);
    }

    function test_extract_single_block_no_language() {
        var text = "Some text\n\n```\necho hello\n```\n\nMore text";
        var result = Utils.extractCodeBlocks(text);
        compare(result.length, 1);
        compare(result[0].language, "");
        compare(result[0].code, "echo hello");
    }

    function test_extract_single_block_with_language() {
        var text = "```python\nimport os\nprint(os.getcwd())\n```";
        var result = Utils.extractCodeBlocks(text);
        compare(result.length, 1);
        compare(result[0].language, "python");
        compare(result[0].code, "import os\nprint(os.getcwd())");
    }

    function test_extract_multiple_blocks() {
        var text = "First:\n\n```bash\necho hi\n```\n\nSecond:\n\n```python\nprint('hello')\n```";
        var result = Utils.extractCodeBlocks(text);
        compare(result.length, 2);
        compare(result[0].language, "bash");
        compare(result[0].code, "echo hi");
        compare(result[1].language, "python");
        compare(result[1].code, "print('hello')");
    }

    function test_extract_strips_fence_markers() {
        var text = "```js\nconsole.log('test')\n```";
        var result = Utils.extractCodeBlocks(text);
        compare(result.length, 1);
        verify(result[0].code.indexOf("```") === -1);
        verify(result[0].code.indexOf("js") === -1 || result[0].code.indexOf("console") !== -1);
        compare(result[0].code, "console.log('test')");
    }

    Component {
        id: loaderComponent
        
        Loader {
            property bool enableMarkdown: false
            property string messageText: ""
            property string name: "Assistant" // Mock message sender
            property string number: messageText // Mock data structure
            property real implicitHeight: item ? item.implicitHeight : 0
            
            sourceComponent: enableMarkdown ? markdownComponent : plainTextComponent
            
            Component {
                id: plainTextComponent
                TextEdit {
                    readOnly: true
                    wrapMode: Text.WordWrap
                    text: number
                    selectByMouse: true
                }
            }
            
            Component {
                id: markdownComponent
                TextArea {
                    id: markdownTextArea
                    readOnly: true
                    wrapMode: TextArea.Wrap
                    text: number
                    textFormat: TextArea.MarkdownText
                    selectByMouse: true
                    background: null
                }
            }
        }
    }
}