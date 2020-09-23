type TError = "Can't access Siri!" | 'Not supported!' | 'Invalid parameters!' | 'Not supported type: siri' | 'Cancelled!' | 'Not Found!' | null;
interface IPerm {
  status: "undetermined" | "restricted" | "denied" | "granted" | "unknown" | "not support";
}
interface IAddParams {
  url: string;
  version: string;
  icon: string;
  token: string;
  sceneName: string;
  sceneId: string;
  suggestedInvocationPhrase: string;
}
interface IShortcut {
  UDID: string;
  sceneId: string;
}

export function setToken(token: string, callback: (err: TError, result: null | 'success') => any): boolean;
export function isSiriShortcutEnabled(callback: (err: TError, result: boolean) => any);
export function requestSiriPermission(): IPerm;
export function siriPermissionStatus(): IPerm;
export function addSiriShortcut(params: IAddParams, callback: (error: TError, result: null | 'success') => void);
export function getAllSiriShortcut(callback: (error: TError, result: IShortcut[]) => void);
export function editSiriShortcut(params: IShortcut, callback: (error: TError, result: null | 'success' ) => void)