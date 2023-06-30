import SwiftUI
 
/// An NSPanel subclass that implements floating panel traits.
class FloatingPanel<Content: View>: NSPanel {
    init(view: () -> Content,
         contentRect: NSRect,
         backing: NSWindow.BackingStoreType = .buffered,
         defer flag: Bool = false)
    {
        /// Init the window as usual
        super.init(contentRect: contentRect,
                   styleMask: [.nonactivatingPanel, .closable, .borderless],
                   backing: backing,
                   defer: flag)

        isFloatingPanel = true
        level = .floating
        ignoresMouseEvents = true
        animationBehavior = .utilityWindow
        backgroundColor = .clear
        
        /// Set the content view.
        /// The safe area is ignored because the title bar still interferes with the geometry
        contentView = NSHostingView(rootView: view()
            .frame(minWidth: 0,
                   maxWidth: .infinity,
                   minHeight: 0,
                   maxHeight: .infinity,
                   alignment: .topLeading)
            .ignoresSafeArea())
    }
}

class FloatingPanelManager<PanelContent: View>: ObservableObject {
    @Published var isPresented: Bool = false
    
    private var panel: FloatingPanel<PanelContent>?
    
    func presentPanel(content: () -> PanelContent, contentRect: CGRect) {
        if panel == nil {
            panel = FloatingPanel(view: content, contentRect: contentRect)
            panel?.center()
        }
        panel?.setIsVisible(true)
        isPresented = true
    }
    
    func dismissPanel() {
        panel?.setIsVisible(false)
        isPresented = false
    }
}
