import * as core from '@actions/core'
import {getVersion, gitTagExists, fail, success} from './version'
import * as path from 'path'

async function run(): Promise<void> {
  try {
    const file = core.getInput('file', {required: true})
    const prepend = core.getInput('prepend')

    const cwd = process.env.GITHUB_WORKSPACE || process.cwd()
    const filePath = path.join(cwd, file)

    const rawVersion = await getVersion(filePath)
    const version = `${prepend}${rawVersion}`
    core.info(`✅ found ${version} from ${file} file`)

    if (await gitTagExists(version)) {
      return fail(version, file)
    }
    success(version, rawVersion)
  } catch (error) {
    core.setFailed(`🔥 ${error.message}`)
  }
}

run()
