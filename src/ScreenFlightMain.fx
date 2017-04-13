
package com.interactivemesh.j3d.testspace.jfx.screenflight;

import com.javafx.preview.control.MenuItem;
import com.javafx.preview.control.PopupMenu;

import javafx.scene.Scene;
import javafx.scene.control.Separator;

import javafx.scene.input.MouseButton;
import javafx.scene.input.MouseEvent;

import javafx.scene.layout.LayoutInfo;

import javafx.scene.paint.Color;

import javafx.scene.text.Font;
import javafx.scene.text.FontWeight;

import javafx.stage.Screen;
import javafx.stage.Stage;
import javafx.stage.StageStyle;

import javafx.util.Math;

/**
 * ScreenFlightMain.fx
 *
 * Version: 3.0
 * Date: 2010/09/19
 *
 * Copyright (c) 2009-2010
 * August Lammersdorf, InteractiveMesh e.K.
 * Kolomanstrasse 2a, 85737 Ismaning
 * Germany / Munich Area
 * www.InteractiveMesh.com/org
 *
 * Please create your own implementation.
 * This source code is provided "AS IS", without warranty of any kind.
 * You are allowed to copy and use all lines you like of this source code
 * without any copyright notice,
 * but you may not modify, compile, or distribute this 'ScreenFlightMain.fx'.
 *
 */

var menuFont: Font;

class PopupMenuItem extends MenuItem {
    override var font = menuFont
}

//
// Run function
//
function run(args: String[]): Void {
        
    // Full screen ?
    var isScreenSize: Boolean = false;
        
    if (args != null and sizeof args > 0) {
        for (arg in args) {
            if (arg.equalsIgnoreCase("ScreenSize")) {
                isScreenSize = true;
                break;
            }
        }
    }

    def screenHeight: Number = Screen.primary.bounds.height;

    // screenHeight >= 1200
    var menuFontSize = 18;
    // screenHeight  < 1024
    if (screenHeight < 1024) {
        menuFontSize = 14;
    }
    // 1024 <= screenHeight < 1200
    else if (screenHeight < 1200) {
        menuFontSize = 16;
    }

    // Bug RT-9312, since 1.3.1
    // Logical fonts (Dialog, Serif, etc.) overruns, although text doesn't exceed the available space.
    menuFont = Font.font("Amble Cn", FontWeight.BOLD, menuFontSize);
    
    // Frame size
    var stageWidth: Number = screenHeight * 0.75;
    var stageHeight: Number = stageWidth;
    if (isScreenSize) {
        stageWidth = Screen.primary.bounds.width;
        stageHeight = screenHeight;
    }

    // Frame
    var stage: Stage;

    // FXCanvas3D
    def fxCanvas3DComp: FXCanvas3DSBComp = FXCanvas3DSBComp {
        // Resizing
        layoutInfo: LayoutInfo {
            width: bind Math.max(stage.scene.width, 10);    // avoid width <= 0
            height: bind Math.max(stage.scene.height, 10);  // avoid height <= 0
        }

        // Context menu
        
        override var onMousePressed = function(event: MouseEvent): Void {
            if (popupMenu.showing)
                popupMenu.hide();
        }       
        override var onMouseClicked = function(event: MouseEvent): Void {
            if (event.button == MouseButton.SECONDARY) {
                popupMenu.show(fxCanvas3DComp, event.screenX+5, event.screenY);
            }
        }       
    }

    // UniverseFX
    def universeFX = ScreenFlightUniverseFX {
        // Callback of AsyncOperation
        initUniverse: function(universe: ScreenFlightUniverse): Void {
            //
            fxCanvas3DComp.isScreenSize = isScreenSize;
            fxCanvas3DComp.frame = stage;
            // Finish FXCanvas3DComp
            fxCanvas3DComp.initFXCanvas3D(universe);
            // Show frame
            stage.visible = true;
        }
    }

    def popupMenu = PopupMenu {

        var startStopItem: PopupMenuItem;
        var doStart = false;

        layoutInfo: LayoutInfo { height: bind startStopItem.layoutBounds.height * 2.8 }

        items: [
            startStopItem = PopupMenuItem {
                action: function() { universeFX.startStopPropeller(doStart) }
            },
            Separator {},
            PopupMenuItem {
                text: "Exit application"
                action: function() { stage.close() }
            }
        ]

        override var onShowing = function() {
            doStart = not universeFX.isPropellerOn();
            if (doStart) {
                startStopItem.text = "Start propeller";
            }
            else {
                startStopItem.text = "Stop propeller";
            }
        }

        override var onAction = function(item :MenuItem):Void { hide() }

        visible: false
    }

    stage = Stage {
        title: "InteractiveMesh : ScreenFlight"

        onClose: function() {
            universeFX.closeUniverse();
        }

        style: StageStyle.TRANSPARENT

        fullScreen: false
        resizable: false
        visible: false

        width: stageWidth
        height: stageHeight

        scene: Scene {
            fill: Color.TRANSPARENT
            content: [ popupMenu, fxCanvas3DComp ]
        }
    }

    //
    // Start
    //
    // JavaTaskBase
    universeFX.start();
}
