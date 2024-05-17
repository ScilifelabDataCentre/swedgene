/* global JBrowseReactApp React, ReactDOM */

const { createViewState, JBrowseApp } = window.JBrowseReactApp

function RenderJBrowse(filePath) {
  fetch(filePath)
    .then(response => response.json())
    .then(config => {
      const viewState = createViewState({ config })

      ReactDOM.render(
        React.createElement(JBrowseApp, { viewState }),
        document.getElementById('jbrowse_app'),
      )
    })
}

// gets file path from HTML file
const configFilePath = document.getElementById('jbrowse_app').dataset.configFilePath;
RenderJBrowse(configFilePath);