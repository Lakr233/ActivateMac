//
//  main.swift
//  ActivateMac
//
//  Created by Lakr Aream on 2022/5/17.
//

import AppKit

let app = NSApplication.shared
let appDelegate = AppDelegate()
app.delegate = appDelegate

_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_: Notification) {
        NSApp.setActivationPolicy(.accessory)
        bootstrapWindows()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(bootstrapWindows),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )
    }

    var windows: [NSWindowController] = []

    @objc
    func bootstrapWindows() {
        windows.forEach { window in
            window.close()
        }
        windows = []

        for screen in NSScreen.screens {
            windows.append(createWindow(for: screen))
        }
    }

    func createWindow(for screen: NSScreen) -> NSWindowController {
        let window = ActivateWindowController(with: screen)
        window.window?.setContentSize(screen.frame.size)
        return window
    }
}

class ActivateWindow: NSWindow {
    init(with screen: NSScreen) {
        super.init(
            contentRect: screen.frame,
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        isOpaque = false
        alphaValue = 1

        titleVisibility = .hidden
        titlebarAppearsTransparent = true

        backgroundColor = .clear

        ignoresMouseEvents = true
        isMovable = false
        isMovableByWindowBackground = false

        collectionBehavior = .init(rawValue: 0x101) // 1 | 1 << 8
        styleMask = .borderless

        // The standard ScreenSaverView class actually sets the window
        // level to 2002, not the 1000 defined by NSScreenSaverWindowLevel
        // and kCGScreenSaverWindowLevel
        /// https://github.com/genekogan/ofxScreenGrab/blob/master/src/macGlutfix.m
        level = NSWindow.Level(rawValue: 2005)

        setFrameOrigin(screen.frame.origin)

        makeKeyAndOrderFront(nil)
        hasShadow = false
    }
}

class ActivateWindowController: NSWindowController {
    init(with screen: NSScreen) {
        super.init(window: ActivateWindow(with: screen))
        contentViewController = NSStoryboard(
            name: "Main", bundle: nil
        )
        .instantiateController(withIdentifier: "ActivateController")
        as! ActivateController
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }
}

class ActivateController: NSViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
