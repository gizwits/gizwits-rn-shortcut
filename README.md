
# react-native-gizwits-shortcut

## Getting started

`$ npm install react-native-gizwits-shortcut --save`

### Mostly automatic installation

`$ react-native link react-native-gizwits-shortcut`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-gizwits-shortcut` and add `RNGizwitsShortcut.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNGizwitsShortcut.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNGizwitsShortcutPackage;` to the imports at the top of the file
  - Add `new RNGizwitsShortcutPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-gizwits-shortcut'
  	project(':react-native-gizwits-shortcut').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-gizwits-shortcut/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-gizwits-shortcut')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNGizwitsShortcut.sln` in `node_modules/react-native-gizwits-shortcut/windows/RNGizwitsShortcut.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Gizwits.Shortcut.RNGizwitsShortcut;` to the usings at the top of the file
  - Add `new RNGizwitsShortcutPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import RNGizwitsShortcut from 'react-native-gizwits-shortcut';

// TODO: What to do with the module?
RNGizwitsShortcut;
```
  