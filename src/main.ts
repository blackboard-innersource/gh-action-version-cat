import * as core from '@actions/core'
import {getVersion, gitTagExists, fail} from './version'
import * as path from 'path'

async function run(): Promise<void> {
  try {
    const file = core.getInput('file', {required: true})
    const prepend = core.getInput('prepend')

    const cwd = process.env.GITHUB_WORKSPACE || process.cwd()
    const filePath = path.join(cwd, file)

    const version = await getVersion(filePath, prepend)
    core.info(`✅ found ${version} from ${file} file`)

    if (await gitTagExists(version)) {
      return fail(version, file)
    }

    core.info(`✅ git tag ${version} is available`)
    core.setOutput('version', version)
  } catch (error) {
    core.setFailed(`🔥 ${error.message}`)
  }
}

run()
