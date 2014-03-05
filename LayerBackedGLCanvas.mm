#include <wx/wxprec.h>

#import "LayerBackedGLCanvas.hpp"

#ifndef WX_PRECOMP
    #include <wx/frame.h>
    #include <wx/log.h>
    #include <wx/settings.h>
#endif

#include <wx/osx/private.h>
#include <OpenGL/OpenGL.h>
#include <OpenGL/gl.h>

@interface LayerBackedGLCanvasLayer : NSOpenGLLayer
{
@private
    LayerBackedGLCanvas * m_canvas;
}
@end

@implementation LayerBackedGLCanvasLayer

- (id)init
{
    m_canvas = nil;
    return [super init];
}

- (void)drawInCGLContext:(CGLContextObj)ctx pixelFormat:(CGLPixelFormatObj)pf
            forLayerTime:(CFTimeInterval)t displayTime:(const CVTimeStamp *)ts
{
    CGLSetCurrentContext(ctx);
    if (m_canvas) {
        m_canvas->OnOpenGLDraw(ctx);
    }
}

- (void)setCanvas:(LayerBackedGLCanvas *)canvas
{
    m_canvas = canvas;
}

- (BOOL)canDrawInCGLContext:(CGLContextObj)ctx
                pixelFormat:(CGLPixelFormatObj)pf forLayerTime:(CFTimeInterval)t
                displayTime:(const CVTimeStamp *)ts
{
    return m_canvas != nullptr && m_canvas->GetPeer()->GetNeedsDisplay();
}

- (BOOL)isOpaque
{
    return YES;
}

@end


@interface LayerBackedGLCanvasView : NSView
{}
@end


@implementation LayerBackedGLCanvasView

+ (void)initialize
{
    static BOOL initialized = NO;
    if (!initialized)
    {
        initialized = YES;
        wxOSXCocoaClassAddWXMethods( self );
    }
}

- (CALayer *)makeBackingLayer
{
    LayerBackedGLCanvasLayer * result = [[LayerBackedGLCanvasLayer alloc] init];
    [result setNeedsDisplayOnBoundsChange: YES];
    [result setAsynchronous: YES];
    return [result autorelease];
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)isOpaque
{
    return NO;
}

@end


IMPLEMENT_CLASS(LayerBackedGLCanvas, wxWindow)

BEGIN_EVENT_TABLE(LayerBackedGLCanvas, wxWindow)
END_EVENT_TABLE()


LayerBackedGLCanvas::LayerBackedGLCanvas(wxWindow *parent,
                                         wxWindowID id,
                                         const int *attribList,
                                         const wxPoint& pos,
                                         const wxSize& size,
                                         long style,
                                         const wxString& name,
                                         const wxPalette& palette)
{
    Create(parent, id, pos, size, style, name, attribList, palette);
}


bool LayerBackedGLCanvas::Create(wxWindow *parent,
                                 wxWindowID id,
                                 const wxPoint& pos,
                                 const wxSize& size,
                                 long style,
                                 const wxString& name,
                                 const int *attribList,
                                 const wxPalette& WXUNUSED(palette))
{
    DontCreatePeer();
    
    if (!wxWindow::Create(parent, id, pos, size, style, name)) {
        return false;
    }
    
    NSRect r = wxOSXGetFrameForControl( this, pos , size ) ;
    LayerBackedGLCanvasView* v = [[LayerBackedGLCanvasView alloc] initWithFrame:r];
    [v setWantsLayer:YES];
    [v setWantsBestResolutionOpenGLSurface: YES];
    LayerBackedGLCanvasLayer * layer = (LayerBackedGLCanvasLayer *)[v layer];
    [layer setCanvas: this];
    SetPeer(new wxWidgetCocoaImpl( this, v ));
    
    MacPostControlCreate( pos, size );
    
    return true;
}

LayerBackedGLCanvas::~LayerBackedGLCanvas()
{}

void LayerBackedGLCanvas::OnOpenGLDraw(CGLContextObj WXUNUSED(context))
{
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
}
