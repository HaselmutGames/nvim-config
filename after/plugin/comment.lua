require('Comment').setup({
    pre_hook = function (ctx)
        local ok, ts_comment = pcall(require, 'ts_context_commentstring.integrations.comment_nvim')
        if ok then
            return ts_comment.create_pre_hook()(ctx)
        end
    end,
})
