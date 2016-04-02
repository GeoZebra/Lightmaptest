﻿// Alloy Physical Shader Framework
// Copyright 2013-2015 RUST LLC.
// http://www.alloy.rustltd.com/

using System;
using System.IO;
using System.Linq;
using UnityEditor;
using UnityEngine;
using Alloy;
using Object = UnityEngine.Object;

public class AlloyMaterialMapChannelPacker : EditorWindow {
	protected const string EditorPathRoot = "Window/Alloy/";
	protected const string SelectTextureOrValueErrorMessage = "Please select a texture or a value.";
	protected const string EnterFilenameErrorMessage = "Please enter a filename.";

	private const string c_assetPathRoot = "Assets";
	private const string c_defaultFilename = "Output";

	protected Vector2 ScrollPosition = new Vector2(0, 0);

	[SerializeField]
	protected string SaveName = string.Empty;

	private static Texture2D s_rectTexture;
	private static GUIStyle s_staticRectStyle;

	private void OnEnable() {
		SaveName = GetSelectedOrDefaultFilename();
		Undo.undoRedoPerformed += UndoRedoPerformed;

	}

	private void OnSelectionChange() {
		Repaint();
		SaveName = GetSelectedOrDefaultFilename();
	}

	protected string GetSelectedAssetPath() {
		var path = c_assetPathRoot;

		foreach (Object obj in Selection.GetFiltered(typeof(Object), SelectionMode.Assets)) {
			path = AssetDatabase.GetAssetPath(obj);

			if (File.Exists(path)) {
				path = Path.GetDirectoryName(path);
			}

			break;
		}

		return path;
	}

	protected string GetSelectedOrDefaultFilename() {
		string fileName;

		var path = AssetDatabase.GetAssetPath(Selection.activeObject);

		if (string.IsNullOrEmpty(path) || !Path.HasExtension(path)) {
			fileName = c_defaultFilename;
		} else {
			fileName = Path.GetFileNameWithoutExtension(path);
		}

		return fileName;
	}

	protected void TitleLabel(string text) {
		GUILayout.Label(text, EditorStyles.boldLabel, GUILayout.Width(150.0f));
	}

	protected void HelpLabel(string text) {
		GUI.color = EditorGUIUtility.isProSkin ? Color.gray : Color.black;
		var wrappedWhiteLabel = new GUIStyle(EditorStyles.whiteLabel);
		wrappedWhiteLabel.wordWrap = true;
		GUILayout.Label(text, wrappedWhiteLabel);
	}

	// Note that this function is only meant to be called from OnGUI() functions.
	public static void GUIDrawRect(Rect position, Color color) {
		if (s_rectTexture == null) {
			// Use this format so that input colors are treated as though they
			// are in gamma-space.
			s_rectTexture = new Texture2D(1, 1, TextureFormat.RGB24, false, true);
		}

		if (s_staticRectStyle == null) {
			s_staticRectStyle = new GUIStyle();
		}

		s_rectTexture.SetPixel(0, 0, color);

		s_rectTexture.Apply();
		s_staticRectStyle.normal.background = s_rectTexture;

		GUI.Box(position, GUIContent.none, s_staticRectStyle);
	}

	protected bool FileEntryAndSaveGUI(string suffix, string extension, bool enabled, ref string filename,
									   out string curPath) {
		curPath = GetSelectedAssetPath();
		var displayPath = curPath + "/";

		if (filename.Contains(suffix)) {
			int fileExtPos = filename.LastIndexOf(suffix, StringComparison.Ordinal);

			if (fileExtPos >= 0) {
				filename = filename.Substring(0, fileExtPos);
			}
		}

		displayPath = displayPath.Remove(0, 7);
		var dirs = displayPath.Split('/');
		var dirsCount = dirs.Length - 4;

		for (int i = 0; i < dirsCount; i++) {
			dirs[i] = "..";
		}

		displayPath = string.Join("/", dirs);

		// Output filename section.
		using (new EditorGUILayout.VerticalScope()) {
			using (new EditorGUILayout.HorizontalScope()) {
				Color defaultContentColor = GUI.contentColor;
				GUI.contentColor = EditorGUIUtility.isProSkin ? Color.yellow : Color.black;
				GUILayout.Label(displayPath, EditorStyles.whiteLabel);
				GUI.contentColor = defaultContentColor;

				GUILayout.Space(10.0f);
				SaveName = GUILayout.TextField(filename, GUILayout.Width(180.0f));
				GUILayout.Label(suffix + extension);
				GUILayout.FlexibleSpace();
			}
		}

		GUILayout.Space(5.0f);

		// Warning message.
		bool wrong = false;

		using (new EditorGUILayout.HorizontalScope()) {
			if (string.IsNullOrEmpty(filename)) {
				EditorGUILayout.HelpBox(EnterFilenameErrorMessage, MessageType.Warning);
				wrong = true;
			}

			if (filename.Contains("/") || filename.Contains("\\") || filename.Contains(".")) {
				EditorGUILayout.HelpBox("Name is not valid!", MessageType.Warning);
				wrong = true;
			}

			GUILayout.FlexibleSpace();
		}

		// "Generate" button section.
		// Disable the button if the editor doesn't have all the fields set.
		GUI.enabled = enabled && !wrong;

		bool isButtonClicked;
		using (new EditorGUILayout.HorizontalScope()) {
			GUILayout.FlexibleSpace();
			isButtonClicked = GUILayout.Button("Generate", EditorStyles.toolbarButton, GUILayout.Width(120.0f),
				GUILayout.Height(70.0f));
			GUILayout.FlexibleSpace();
		}

		GUI.enabled = true;
		GUILayout.Space(5.0f);

		return isButtonClicked;
	}


	[SerializeField] public AlloyCustomImportObject Target;

	private static MaterialMapChannelPackerDefinition s_definition;

	public static MaterialMapChannelPackerDefinition GlobalDefinition {
		get {
			if (s_definition == null) {
				string path = "Assets/Alloy/Scripts/MaterialMapChannelPacker/Editor/packerDefinition.asset";
				s_definition =
					AssetDatabase.LoadAssetAtPath(path, typeof (MaterialMapChannelPackerDefinition)) as
						MaterialMapChannelPackerDefinition;

				if (s_definition == null) {
					s_definition = CreateInstance<MaterialMapChannelPackerDefinition>();

					AssetDatabase.CreateAsset(s_definition, path);
				}
			}

			return s_definition;
		}
	}

	private const int c_editorMinWidth = 236;

	[MenuItem(EditorPathRoot + "Material Map Channel Packer", false, 0)]
	private static void LoadWindow() {
		var all = Resources.FindObjectsOfTypeAll<AlloyMaterialMapChannelPacker>();

		foreach (var channelPacker in all) {
			DestroyImmediate(channelPacker);
		}

		GetWindow<AlloyMaterialMapChannelPacker>(false, "Material Map");
	}


	private void UndoRedoPerformed() {
		Target.ClearCache();
		Repaint();
	}

	private void OnDisable() {
		if (!EditorUtility.IsPersistent(Target)) {
			DestroyImmediate(Target);
		}

		Undo.undoRedoPerformed -= UndoRedoPerformed;
	}


	private void OnGUI() {
		if (Target == null) {
			Target = CreateInstance<AlloyCustomImportObject>();
			UpdateDefaults();
		}

		ScrollPosition = EditorGUILayout.BeginScrollView(ScrollPosition, false, false,
			GUILayout.MinWidth(c_editorMinWidth),
			GUILayout.MaxWidth(position.width));

		GUILayout.Space(10.0f);
		var def = Target.PackMode;

		// Pack mode tabs.
		using (new EditorGUILayout.HorizontalScope()) {

			foreach (var tabMode in GlobalDefinition.PackedMaps) {
				EditorGUI.BeginChangeCheck();
				bool toggle = GUILayout.Toggle(def == tabMode, tabMode.Title, EditorStyles.toolbarButton);

				if (EditorGUI.EndChangeCheck()) {
					if (toggle && def != tabMode) {
						Target.PackMode = tabMode; //Update packed map definition

						UpdateDefaults();
					}
				}
			}
		}

		DoBaseGUI();


		var enabled = true;
		for (int i = 0; i < 4; ++i) {
			if (Target.SelectedModes[i] == TextureValueChannelMode.Texture && Target.GetTexture(i) == null) {
				enabled = false;
				break;
			}
		}

		string curPath;
		var suffix = Target.PackMode.Suffix;

		if (FileEntryAndSaveGUI(suffix, ".png", enabled, ref SaveName, out curPath)) {
			var path = curPath + "/" + SaveName;
			path += suffix;

			var current = Target;

			Target = Instantiate(current);

			AlloyCustomImportAction.CreatePostProcessingInformation(path + ".asset", current);
		}

		EditorGUILayout.EndScrollView();
	}

	private void UpdateDefaults() {

		var def = Target.PackMode;

		foreach (var channel in def.Channels) {
			var outIndices = channel.OutputIndices.ToArray();
			
			for (int i = 0; i < outIndices.Length; ++i) {
				Target.SelectedModes[outIndices[i]] = channel.DefaultMode;
			}
		}
	}

	private void DrawPackedMapDefinition(PackedMapDefinition def) {
		bool anyNrm = false;

		foreach (var channel in def.Channels) {
			if (!(channel.OutputVariance || channel.HideChannel)) {
				DrawChannel(channel, false);
			}

			if (channel.UseNormals) {
				anyNrm = true;
			}
		}

		if (anyNrm) {
			DrawChannel(GlobalDefinition.NRMChannel, true);
		}

		using (new EditorGUILayout.VerticalScope("HelpBox")) {
			TitleLabel("Auto Regenerate");

			using (new EditorGUILayout.HorizontalScope()) {
				HelpLabel(GlobalDefinition.AutoRegenerateText);
				GUI.color = Color.white;
				GUILayout.FlexibleSpace();
				Target.DoAutoRegenerate = EditorGUILayout.Toggle("", Target.DoAutoRegenerate, GUILayout.Width(120.0f));
			}

			if (def.Channels.Any(c => c.UseNormals) && def.VarianceBias) {
				TitleLabel("Variance Bias");

				using (new EditorGUILayout.HorizontalScope()) {
					HelpLabel(GlobalDefinition.VarianceText);
					GUI.color = Color.white;
					GUILayout.FlexibleSpace();

					Target.VarianceBias = EditorGUILayout.Slider(Target.VarianceBias, 0.0f, 1.0f, GUILayout.Width(120.0f));
				}
			}
		}
	}

	private void DrawChannel(BaseTextureChannelMapping def, bool normal) {
		GUI.backgroundColor = def.BackgroundColor;

		using (new EditorGUILayout.VerticalScope("HelpBox")) {
			GUI.backgroundColor = Color.white;

			using (new EditorGUILayout.HorizontalScope()) {
				var map = def as MapTextureChannelMapping;

				using (new EditorGUILayout.VerticalScope()) {
					using (new EditorGUILayout.HorizontalScope()) {
						TitleLabel(def.Title);

						if (map != null) {
							string inChannel = map.InputString;
							string outChannel = map.OutputString;

							HelpLabel("("  + inChannel + "  →  " + outChannel + ")");
						}
					}
					HelpLabel(def.HelpText);

					GUI.color = Color.white;

					if (normal) {
						if (Target.NormalMapTexture == null) {
							EditorGUILayout.HelpBox("Recommended, but not required.", MessageType.Info);
						}
					} else if (map != null) {
						if ((Target.SelectedModes[map.MainIndex] == TextureValueChannelMode.Texture) &&
							Target.GetTexture(map.MainIndex) == null) {
							EditorGUILayout.HelpBox(SelectTextureOrValueErrorMessage, MessageType.Warning);
						}
					}
				}

				GUILayout.FlexibleSpace();

				if (normal) {
					Target.NormalMapTexture =
						EditorGUILayout.ObjectField(Target.NormalMapTexture, typeof (Texture2D), false, GUILayout.Width(70.0f),
							GUILayout.Height(70.0f))
							as Texture2D;
				} else if (map != null) {
					int texIndex = map.MainIndex;

					var mode = Target.SelectedModes[texIndex];
					int index = (int) mode;
					GUILayout.BeginVertical();

					bool ch1 = GUILayout.Toggle(index == 0, "Black", EditorStyles.toolbarButton);
					bool ch2 = GUILayout.Toggle(index == 1, "Gray", EditorStyles.toolbarButton);
					bool ch3 = GUILayout.Toggle(index == 2, "White", EditorStyles.toolbarButton);
					bool ch4 = GUILayout.Toggle(index == 3, "Custom", EditorStyles.toolbarButton);
					bool ch5 = GUILayout.Toggle(index == 4, "Texture", EditorStyles.toolbarButton);

					float channelValue = 0.0f;

					if (ch1 && index != 0) {
						index = 0;
					} else if (ch2 && index != 1) {
						index = 1;
					} else if (ch3 && index != 2) {
						index = 2;
					} else if (ch4 && index != 3) {
						index = 3;
					} else if (ch5 && index != 4) {
						index = 4;
					}

					GUILayout.EndVertical();

					var selTex = Target.GetTexture((int) texIndex);

					if (mode != TextureValueChannelMode.Texture) {
						selTex = null;
					}

					GUILayout.Space(10.0f);
					// Color or texture picker.
					switch (mode) {
						case TextureValueChannelMode.Texture:
							using (new EditorGUILayout.VerticalScope()) {
								selTex =
									EditorGUILayout.ObjectField(selTex, typeof (Texture2D), false, GUILayout.Width(70.0f), GUILayout.Height(70.0f))
										as Texture2D;

								if (map.CanInvert) {
									float label = EditorGUIUtility.labelWidth;
									EditorGUIUtility.labelWidth = 60.0f;
									Target.DoInvert[texIndex] = EditorGUILayout.Toggle("Invert", Target.DoInvert[texIndex], GUILayout.Width(70.0f));
									EditorGUIUtility.labelWidth = label;
								}
							}
							
							Target.SetTexture(selTex, texIndex);

							foreach (var mapIndex in map.OutputIndices) {
								Target.SetTexture(selTex, mapIndex);
								Target.DoInvert[mapIndex] = Target.DoInvert[texIndex];
							}
							break;


						case TextureValueChannelMode.Black:
							channelValue = 0.0f;
							DrawColorBox(Color.black);
							break;
						case TextureValueChannelMode.Gray:
							channelValue = 0.5f;
							DrawColorBox(Color.gray);
							break;
						case TextureValueChannelMode.White:
							channelValue = 1.0f;
							DrawColorBox(Color.white);
							break;

						case TextureValueChannelMode.Custom:
							channelValue = Target.ChannelValues[(int) texIndex];
							EditorGUILayout.BeginVertical();
							channelValue = Mathf.Clamp01(channelValue);
							channelValue = EditorGUILayout.FloatField(channelValue,
							GUILayout.Width(50.0f));

							DrawColorBox(new Color(channelValue, channelValue, channelValue));
							EditorGUILayout.EndVertical();
							break;
					}

					if (mode != TextureValueChannelMode.Texture) {
						foreach (var mapIndex in map.OutputIndices) {
							Target.DoInvert[mapIndex] = false;
						}
					}

					Target.ChannelValues[texIndex] = channelValue;
					Target.SelectedModes[texIndex] = (TextureValueChannelMode) index;

					foreach (var mapIndex in map.OutputIndices) {
						Target.ChannelValues[mapIndex] = channelValue;
						Target.SelectedModes[mapIndex] = (TextureValueChannelMode) index;
					}
				}
			}

			GUILayout.Space(10.0f);
		}
	}

	private static void DrawColorBox(Color col) {
		var rect = GUILayoutUtility.GetRect(74.0f, 74.0f);
		var borderColor = new Color {
										r = (col.r + 0.2f) / 2.0f,
										g = (col.g + 0.2f) / 2.0f,
										b = (col.b + 0.2f) / 2.0f,
										a = 1.0f
									};

		GUIDrawRect(rect, borderColor);

		rect.x += 2.0f;
		rect.width -= 4.0f;
		rect.y += 2.0f;
		rect.height -= 4.0f;

		GUIDrawRect(rect, col);
	}

	public void DoBaseGUI() {
		EditorGUI.BeginChangeCheck();
		Undo.RecordObject(Target, "Packed map");

		DrawPackedMapDefinition(Target.PackMode);

		if (EditorGUI.EndChangeCheck()) {
			EditorUtility.SetDirty(Target);
		}
	}
}