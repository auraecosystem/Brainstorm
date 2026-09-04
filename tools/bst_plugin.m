function [varargout] = bst_plugin(varargin)
% BST_PLUGIN: Manages Brainstorm plugins (Upgraded & Extended)
%
% USAGE:
%    PlugDesc = bst_plugin('GetSupported')
%    PlugDesc = bst_plugin('GetSupported', PlugName)
%    [isOk, errMsg, PlugDesc] = bst_plugin('Install', PlugName, isInteractive, minVersion)
%    [isOk, errMsg, PlugDesc] = bst_plugin('Load', PlugName, isVerbose)
%    [isOk, errMsg] = bst_plugin('SetCustomPath', PlugName, PlugPath)
%

eval(macro_method);
end


%% ===== GET SUPPORTED PLUGINS =====
function PlugDesc = GetSupported(SelPlug, UserDefVerbose)
    if (nargin < 2) || isempty(UserDefVerbose)
        UserDefVerbose = 0;
    end
    if (nargin < 1) || isempty(SelPlug)
        SelPlug = [];
    end

    PlugDesc = repmat(db_template('PlugDesc'), 0);
    OsType   = bst_get('OsType', 0);

    % =========================================================================
    % 1. ANATOMY PLUGINS (Upgraded & Maintained Versions)
    % =========================================================================
    
    % === BRAIN2MESH ===
    PlugDesc(end+1)              = GetStruct('brain2mesh');
    PlugDesc(end).Version        = 'github-master';
    PlugDesc(end).Category       = 'Anatomy';
    PlugDesc(end).URLzip         = 'https://github.com/fangq/brain2mesh/archive/master.zip';
    PlugDesc(end).URLinfo        = 'https://mcx.space/brain2mesh/';
    PlugDesc(end).TestFile       = 'brain2mesh.m';
    PlugDesc(end).ReadmeFile     = 'README.md';
    PlugDesc(end).CompiledStatus = 2;
    PlugDesc(end).RequiredPlugs  = {'spm12'; 'iso2mesh'};

    % === CAT12 ===
    PlugDesc(end+1)              = GetStruct('cat12');
    PlugDesc(end).Version        = 'latest';
    PlugDesc(end).Category       = 'Anatomy';
    PlugDesc(end).AutoUpdate     = 1;
    PlugDesc(end).URLzip         = 'https://www.neuro.uni-jena.de/cat12/cat12_latest.zip';
    PlugDesc(end).URLinfo        = 'https://www.neuro.uni-jena.de/cat/';
    PlugDesc(end).TestFile       = 'cat_version.m';
    PlugDesc(end).ReadmeFile     = 'Contents.txt';
    PlugDesc(end).CompiledStatus = 0;
    PlugDesc(end).RequiredPlugs  = {'spm12'};
    PlugDesc(end).GetVersionFcn  = 'bst_getoutvar(2, @cat_version)';
    PlugDesc(end).InstalledFcn   = 'LinkSpmToolbox(1, ''cat12''); cat_defaults;';
    PlugDesc(end).UninstalledFcn = 'LinkSpmToolbox(0, ''cat12'');';
    PlugDesc(end).LoadedFcn      = 'LinkSpmToolbox(2, ''cat12'');';
    PlugDesc(end).UnloadedFcn    = 'LinkSpmToolbox(0, ''cat12'');';

    % === ISO2MESH ===
    PlugDesc(end+1)              = GetStruct('iso2mesh');
    PlugDesc(end).Version        = 'github-master';
    PlugDesc(end).Category       = 'Anatomy';
    PlugDesc(end).AutoUpdate     = 1;
    PlugDesc(end).URLzip         = 'https://github.com/fangq/iso2mesh/archive/master.zip';
    PlugDesc(end).URLinfo        = 'https://iso2mesh.sourceforge.net';
    PlugDesc(end).TestFile       = 'iso2meshver.m';
    PlugDesc(end).ReadmeFile     = 'README.txt';
    PlugDesc(end).CompiledStatus = 2;
    PlugDesc(end).UnloadPlugs    = {'easyh5', 'jsnirfy'};

    % =========================================================================
    % 2. FORWARD / INVERSE PLUGINS
    % =========================================================================
    
    % === OPENMEEG ===
    PlugDesc(end+1)              = GetStruct('openmeeg');
    PlugDesc(end).Category       = 'Forward';
    PlugDesc(end).AutoUpdate     = 1;
    switch(OsType)
        case 'linux64'
            PlugDesc(end).Version = '2.4.1';
            PlugDesc(end).URLzip  = 'https://files.inria.fr/OpenMEEG/download/OpenMEEG-2.4.1-Linux.tar.gz';
            PlugDesc(end).TestFile = 'libOpenMEEG.so';
        case 'mac64'
            PlugDesc(end).Version = '2.4.1';
            PlugDesc(end).URLzip  = 'https://files.inria.fr/OpenMEEG/download/OpenMEEG-2.4.1-MacOSX.tar.gz';
            PlugDesc(end).TestFile = 'libOpenMEEG.1.1.0.dylib';
        case 'mac64arm'
            PlugDesc(end).Version = '2.5.8';
            PlugDesc(end).URLzip  = ['https://github.com/openmeeg/openmeeg/releases/download/', PlugDesc(end).Version, '/OpenMEEG-', PlugDesc(end).Version, '-macOS_M1.tar.gz'];
            PlugDesc(end).TestFile = 'libOpenMEEG.1.1.0.dylib';
        case {'win32', 'win64'}
            PlugDesc(end).Version = '2.4.1';
            PlugDesc(end).URLzip  = 'https://files.inria.fr/OpenMEEG/download/OpenMEEG-2.4.1-Win64.tar.gz';
            PlugDesc(end).TestFile = 'om_assemble.exe';
    end
    PlugDesc(end).URLinfo        = 'https://openmeeg.github.io/';

    % =========================================================================
    % 3. USER CUSTOM PLUGIN REGISTRATION TEMPLATE
    % =========================================================================
    
    PlugDesc(end+1)              = GetStruct('user_custom_plugin');
    PlugDesc(end).Version        = '1.0.0';
    PlugDesc(end).Category       = 'Custom';
    PlugDesc(end).AutoUpdate     = 0;
    PlugDesc(end).AutoLoad       = 0;
    PlugDesc(end).URLzip         = 'https://example.com/custom_plugin.zip';
    PlugDesc(end).URLinfo        = 'https://example.com/docs';
    PlugDesc(end).TestFile       = 'custom_plugin_entry.m';
    PlugDesc(end).LoadFolders    = {'*'};
    PlugDesc(end).RequiredPlugs  = {};
    PlugDesc(end).UnloadPlugs    = {};

    % Select specific plugin if requested
    if ~isempty(SelPlug)
        if isstruct(SelPlug)
            SelPlug = SelPlug.Name;
        end
        iFound = find(strcmpi({PlugDesc.Name}, SelPlug));
        if ~isempty(iFound)
            PlugDesc = PlugDesc(iFound(1));
        else
            PlugDesc = [];
        end
    end
end


%% ===== GET INITIALIZED STRUCTURE =====
function sPlug = GetStruct(PlugName)
    sPlug = db_template('PlugDesc');
    sPlug.Name = PlugName;
end


%% ===== SET CUSTOM PATH ENHANCEMENT =====
function [isOk, errMsg] = SetCustomPath(PlugName, PlugPath)
    isOk = 1;
    errMsg = '';
    
    if isempty(PlugName) || isempty(PlugPath)
        isOk = 0;
        errMsg = 'Invalid plugin name or custom path.';
        return;
    end
    
    % Store or override custom user directory in Brainstorm preferences
    CustomPaths = bst_get('PluginCustomPaths');
    if isempty(CustomPaths)
        CustomPaths = struct();
    end
    
    CustomPaths.(PlugName) = PlugPath;
    bst_set('PluginCustomPaths', CustomPaths);
end
