#pragma once

#include <wx/defs.h>
#include <wx/app.h>
#include <wx/palette.h>
#include <wx/window.h>
#include <OpenGL/CGLTypes.h>

/**
 * LayerBackedGLCanvas is a class for displaying OpenGL graphics with Layer-Backed mode.
 * @seealso	   About Layer-Backed OpenGL drawing:
 *             https://developer.apple.com/library/mac/samplecode/LayerBackedOpenGLView/Introduction/Intro.html
 */
class LayerBackedGLCanvas : public wxWindow
{
public:
    LayerBackedGLCanvas(wxWindow *parent,
						wxWindowID id = wxID_ANY,
						const int *attribList = NULL,
						const wxPoint& pos = wxDefaultPosition,
						const wxSize& size = wxDefaultSize,
						long style = 0,
						const wxString& name = "",
						const wxPalette& palette = wxNullPalette);

    bool Create(wxWindow *parent,
                wxWindowID id = wxID_ANY,
                const wxPoint& pos = wxDefaultPosition,
                const wxSize& size = wxDefaultSize,
                long style = 0,
                const wxString& name = "",
                const int *attribList = NULL,
                const wxPalette& palette = wxNullPalette);

	virtual ~LayerBackedGLCanvas();

	/**
	 * @brief	Draw the canavs. Override this function and put your all OpenGL API calls in it.
	 */
	virtual void OnOpenGLDraw(CGLContextObj context);

protected:
    DECLARE_EVENT_TABLE()
    DECLARE_CLASS(LayerBackedGLCanvas)
};
