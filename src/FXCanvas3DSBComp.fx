
package com.interactivemesh.j3d.testspace.jfx.screenflight;


import java.lang.System;

import javax.swing.JPanel;

import javafx.ext.swing.SwingComponent;
import javafx.stage.Stage;
import javafx.scene.input.MouseEvent;

import javafx.util.Math;

// FXCanvas3D API 3.0
import com.interactivemesh.j3d.community.gui.FXCanvas3DSB;
import com.interactivemesh.j3d.community.gui.FXCanvas3DRepainter;

/**
 * FXCanvas3DSBComp.fx
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
 * but you may not modify, compile, or distribute this 'FXCanvas3DSBComp.fx'.
 *
 */

package class FXCanvas3DSBComp extends SwingComponent, FXCanvas3DRepainter {

    // Parent of FXCanvas3DSB
    var container: JPanel;

    // FXCanvas3DSB instance
    var fxCanvas3D: FXCanvas3DSB;

    // Frames per second
    def updatesPerSecond = 2;
    var elapsedFrames: Integer = 20;
    var frameCounter: Integer;
    var startTimePaint: Number = System.nanoTime();
    var endTimePaint: Number;
    var frameDuration: Number;
    package var fpsPaint: Integer;

    package var isScreenSize: Boolean = false;
    package var frame: Stage;

    // Drag frame if not full screen
    override var onMouseDragged = function(event: MouseEvent) {
        if (not isScreenSize and event.secondaryButtonDown) {
            frame.x += event.dragX;
            frame.y += event.dragY;
        }
    }

     // Create SwingComponent - called at construction time
    override protected function createJComponent(): JPanel{
        container = new JPanel();
    }

    // Called from Main
    package function initFXCanvas3D(universe: ScreenFlightUniverse) {
        fxCanvas3D = universe.createFXCanvas3D(this, container, isScreenSize);
    }

    // Interface FXCanvas3DRepainter

    // Called from FXCanvas3DSB
    override function repaintFXCanvas3D() {
        /*
         JavaFX API :
         A deferAction represents an action that should be executed
         at a later time of the system's choosing.
         In systems based on event dispatch, such as Swing, execution of a
         deferAction generally means putting it on the event queue for later processing.
        */
        FX.deferAction(
            function(): Void {

                // Now we are in the JavaFX painting loop and on the EDT

                // Repaint FXCanvas3DSB
                // Call doesn't wait, paintComponent() will be called in the next loop !?
                fxCanvas3D.repaint();

                //
                // Frames per second
                //

                frameCounter++;

                if (frameCounter >= elapsedFrames) {

                    endTimePaint = System.nanoTime();
                    frameDuration = (endTimePaint-startTimePaint)/frameCounter;
                    startTimePaint = endTimePaint;

                    fpsPaint = (1000000000 / frameDuration) as Integer;
FX.println(" ScreenFlight : Frames per second = {fpsPaint}");
                    // Reset
                    frameCounter = 0;
                    elapsedFrames = Math.max(1, ((fpsPaint + 0.5) / updatesPerSecond)) as Integer;
                }
            }
        );
    }
}