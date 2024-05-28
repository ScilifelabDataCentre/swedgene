/* global JBrowseReactApp React, ReactDOM */

const { createViewState, JBrowseApp } = window.JBrowseReactApp

// gets file path from HTML file
const configFilePath = document.getElementById('jbrowse_app').dataset.configFilePath;

fetch(configFilePath)
  .then(response => response.json())
  .then(config => {
    const viewState = createViewState({ config })

    const root = ReactDOM.createRoot(document.getElementById('jbrowse_app'))
    root.render(React.createElement(JBrowseApp, { viewState }))
  })