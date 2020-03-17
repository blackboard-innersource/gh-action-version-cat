import * as core from '@actions/core'
import {exists} from '@actions/io/lib/io-util'
import * as fs from 'fs'
import {exec} from '@actions/exec'
import {issueCommand} from '@actions/core/lib/command'

/**
 * Extract the version from the given file.
 *
 * @param {string} filePath - The absolute path to the file.
 */
export async function getVersion(filePath: string): Promise<string> {
  if (!(await exists(filePath))) {
    throw new Error(`failed to find version file: ${filePath}`)
  }
  const content = fs.readFileSync(filePath).toString()
  const lines = content.trim().split(/\r?\n/)

  if (lines.length <= 0 || lines[0] === '') {
    throw new Error(`failed to find version in ${filePath}`)
  }
  return lines[0]
}

/**
 * Determine if the tag exists or not.
 *
 * @param {string} version - The tag name.
 * @param {string} cwd - Optional - current working directory.
 */
export async function gitTagExists(
  version: string,
  cwd?: string
): Promise<boolean> {
  const ref = `refs/tags/${version}`

  try {
    await exec('git', ['fetch', '--depth', '1', 'origin', `+${ref}:${ref}`], {
      silent: true,
      cwd
    })
  } catch (e) {
    return false
  }
  return true
}

/**
 * Fail the action and report the problem.
 *
 * @param {string} version - The version found.
 * @param {string} file - The version file.
 */
export function fail(version: string, file: string): void {
  const properties = {file, line: '1', col: '0'}
  const message = 'This version already exists, please bump accordingly.'
  issueCommand('error', properties, message)
  throw new Error(`git tag ${version} already exists!`)
}

/**
 * Everything is OK, report and set outputs.
 *
 * @param {string} version - The version found.
 * @param {string} rawVersion - The version without the prepended string.
 */
export function success(version: string, rawVersion: string): void {
  core.info(`✅ git tag ${version} is available`)
  core.setOutput('version', version)

  const s = rawVersion.split('.')
  if (s.length !== 3) {
    core.info(`⚠️ could not split version, only version output set`)
    return
  }
  core.info(`✅ split version major=${s[0]} minor=${s[1]} patch=${s[2]}`)
  core.setOutput('major', s[0])
  core.setOutput('minor', s[1])
  core.setOutput('patch', s[2])
}
