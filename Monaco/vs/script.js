require.config({ paths: { vs: "./vs" } });

require(["vs/editor/editor.main"], function () {
  var editor = monaco.editor.getModels()[0];

  var rgbRegex = /\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\)/g;

  function updateColorContainers(rgbCodes) {
    var model = editor;
    var decorations = [];
    var inlineClassName = "color-inline";

    for (var i = 0; i < rgbCodes.length; i++) {
      var rgbCode = rgbCodes[i];
      var match = rgbCode.match(rgbRegex);
      if (match) {
        var red = parseInt(match[1]);
        var green = parseInt(match[2]);
        var blue = parseInt(match[3]);

        var container = document.createElement("div");
        container.classList.add("color-container");

        var colorPreview = document.createElement("div");
        colorPreview.classList.add("color-preview");
        colorPreview.style.backgroundColor = `rgb(${red}, ${green}, ${blue})`;

        var colorCode = document.createTextNode(rgbCode);

        container.appendChild(colorPreview);
        container.appendChild(colorCode);

        var startOffset = model.getValue().indexOf(rgbCode);
        var endOffset = startOffset + rgbCode.length;

        var startLineNumber = model.getPositionAt(startOffset).lineNumber;
        var startColumn = model.getPositionAt(startOffset).column;

        var range = new monaco.Range(
          startLineNumber,
          startColumn,
          startLineNumber,
          startColumn + rgbCode.length
        );
        var colorContainerDecoration = {
          range: range,
          options: {
            isWholeLine: true,
            glyphMarginClassName: "color-glyph-margin",
            linesDecorationsClassName: "color-line-decoration",
            inlineClassName: inlineClassName,
          },
        };

        decorations.push(colorContainerDecoration);
      }
    }

    monaco.editor.setModelDecorations(model, "rgb-decorations", decorations);
  }

  function extractRGBCodes() {
    var editorContent = editor.getValue();
    var rgbCodes = editorContent.match(rgbRegex);

    if (rgbCodes && rgbCodes.length > 0) {
      updateColorContainers(rgbCodes);
    }
  }

  extractRGBCodes();
  editor.onDidChangeModelContent(extractRGBCodes);
});
