
package com.interactivemesh.j3d.testspace.jfx.screenflight;

import javafx.async.JavaTaskBase;
import javafx.async.RunnableFuture;

/**
 * ScreenFlightUniverseFX.fx
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
 * but you may not modify, compile, or distribute this 'ScreenFlightUniverseFX.fx'.
 *
 */

package class ScreenFlightUniverseFX extends JavaTaskBase { 
 
    var universe: ScreenFlightUniverse;

    // Implemented in Main, called here from 'onDone'
    package var initUniverse: function(universe: ScreenFlightUniverse): Void;

    //
    // Universe interaction
    //
    package function isPropellerOn(): Boolean {
        universe.isPropellerOn();
    }
    package function startStopPropeller(start: Boolean) {
        universe.startStopPropeller(start);
    }
    package function closeUniverse() {
        universe.closeUniverse();
    }

    //
    // Implementation of JavaTaskBase
    //
    // Create RunnableFuture: ScreenFlightUniverse
    // Called in function 'start()'
    protected override function create(): RunnableFuture {
        universe = new ScreenFlightUniverse();
        return universe;
    }
    // Called from ScreenFlightMain.fx
    // Initializes the 3D scene : calls run() on RunnableFuture 'universe'
    protected override function start(): Void {
        // Nothing to do
        super.start();
    }
    // Callback: Finish init
    override var onDone = function(): Void {
        initUniverse(universe);
    };
}