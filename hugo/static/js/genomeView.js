/* global JBrowseReactApp React, ReactDOM */
import assembly from './assembly.js'
import tracks from './tracks.js'

const { createViewState, JBrowseApp } = window.JBrowseReactApp

const viewState = createViewState({
  config: {
    assemblies: [assembly],
    tracks,
    defaultSession: {
      drawerPosition: 'right',
      drawerWidth: 384,
      widgets: {
        hierarchicalTrackSelector: {
          id: 'hierarchicalTrackSelector',
          type: 'HierarchicalTrackSelectorWidget',
          view: '1W4A0PtoW_jrR2ivJWccA',
        },
      },
      activeWidgets: {
        hierarchicalTrackSelector: 'hierarchicalTrackSelector',
      },
      minimized: false,
      id: '4uFLaCZavF8jZVRnNKwu5',
      name: 'My session',
      margin: 0,
      views: [
        {
          id: '1W4A0PtoW_jrR2ivJWccA',
          minimized: false,
          type: 'LinearGenomeView',
          offsetPx: 255225,
          bpPerPx: 270.45170378301054,
          displayedRegions: [
            {
              refName: '1',
              start: 0,
              end: 249250621,
              reversed: false,
              assemblyName: 'hg19',
            },
          ],
          tracks: [
            {
              id: 'VHMCqOPyRpURO79uxROPc',
              type: 'VariantTrack',
              configuration: 'pacbio_sv_vcf',
              minimized: false,
              displays: [
                {
                  id: 'z5ZSqorF-sWVMUyEpCqvL',
                  type: 'LinearVariantDisplay',
                  configuration: 'pacbio_sv_vcf-LinearVariantDisplay',
                },
              ],
            },
          ],
        },
      ],
      sessionTracks: [],
      sessionAssemblies: [],
      temporaryAssemblies: [],
      connectionInstances: [],
      sessionConnections: [],
      focusedViewId: '1W4A0PtoW_jrR2ivJWccA',
      sessionPlugins: [],
    },
  },
})

ReactDOM.render(
  React.createElement(JBrowseApp, { viewState }),
  document.getElementById('jbrowse_app'),
)
