use zed_extension_api::{
    self as zed, Command, Extension, LanguageServerId, Result, Worktree, settings::LspSettings,
};

zed::register_extension!(CedarExtension);

struct CedarExtension;
impl Extension for CedarExtension {
    fn new() -> Self {
        Self
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<Command> {
        let binary = self.language_server_binary(language_server_id, worktree)?;
        Ok(Command {
            command: binary.path,
            args: binary.args,
            env: worktree.shell_env(),
        })
    }
}

struct LspBinary {
    path: String,
    args: Vec<String>,
}

impl CedarExtension {
    fn language_server_binary(
        &self,
        language_server_id: &LanguageServerId,
        worktree: &Worktree,
    ) -> Result<LspBinary> {
        let settings = LspSettings::for_worktree(language_server_id.as_ref(), worktree)
            .ok()
            .and_then(|lsp| lsp.binary);

        let args = settings
            .as_ref()
            .and_then(|settings| settings.arguments.clone())
            .unwrap_or_default();

        if let Some(path) = settings.and_then(|settings| settings.path) {
            return Ok(LspBinary { path, args });
        }

        if let Some(path) = worktree.which("cedar-language-server") {
            return Ok(LspBinary { path, args });
        }

        Err("`cedar-language-server` not found".to_string())
    }
}
