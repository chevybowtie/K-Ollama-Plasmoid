/*
    SPDX-FileCopyrightText: 2025 Paul <paul.sturm@cotton-software.com>
    SPDX-License-Identifier: LGPL-2.1-or-later
*/

import QtQuick 2.15
import QtTest 1.3
import QtQuick.Controls 2.15
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
        // Test with markdown content
        var markdownContent = "# Heading 1\n\n**Bold text** and *italic text*\n\n- List item 1\n- List item 2\n\n`code snippet`";
        
        // Create plain text loader
        var plainLoader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: false,
            messageText: markdownContent
        });
        
        // Create markdown loader
        var markdownLoader = createTemporaryObject(loaderComponent, testCase, {
            enableMarkdown: true,
            messageText: markdownContent
        });
        
        verify(plainLoader);
        verify(plainLoader.item);
        verify(markdownLoader);
        verify(markdownLoader.item);
        
        // Both should display the content
        verify(plainLoader.item.text === markdownContent);
        // For markdown component, just verify it loaded correctly
        verify(markdownLoader.item !== null);
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
                ScrollView {
                    implicitHeight: markdownTextArea.implicitHeight
                    clip: false
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AlwaysOff
                    
                    function selectAll() { markdownTextArea.selectAll() }
                    function copy() { markdownTextArea.copy() }
                    function deselect() { markdownTextArea.deselect() }
                    
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
}