import {exists} from '@actions/io/lib/io-util'
import * as fs from 'fs'
import {exec} from '@actions/exec'
import {issueCommand} from '@actions/core/lib/command'

/**
 * Extract the version from the given file
 * @param filePath The absolute path to the file
 * @param prepend Prepend this to the version
 */
export async function getVersion(
  filePath: string,
  prepend: string = ''
): Promise<string> {
  if (!(await exists(filePath))) {
    throw new Error(`failed to find version file: ${filePath}`)
  }
  const content = fs.readFileSync(filePath).toString()
  const lines = content.trim().split(/\r?\n/)

  if (lines.length <= 0 || lines[0] === '') {
    throw new Error(`failed to find version in ${filePath}`)
  }
  return `${prepend}${lines[0]}`
}

/**
 * Determine if the tag exists or not
 * @param version The tag name
 * @param cwd Optional - current working directory
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

export function fail(version: string, file: string): void {
  const properties = {file, line: '1', col: '0'}
  const message = 'This version already exists, please bump accordingly.'
  issueCommand('error', properties, message)
  throw new Error(`git tag ${version} already exists!`)
}
