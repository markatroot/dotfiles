pragma Singleton

import Quickshell

Singleton {

  function tryParseJson(obj) {
    try {
      return JSON.parse(obj)
    } catch (e) {
      console.error(e)
      return null
    }
  }

}

