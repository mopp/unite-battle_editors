scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:beSource = {
            \ 'name' : 'battle_editors',
            \ 'default_action': {'*': 'open'},
            \ 'action_table': {},
            \ }


" define unite source
function! unite#sources#battle_editors#define()
    return s:beSource
endfunction


" define unite action
let s:beSource.action_table.open = { 'description': 'open selected article in buffer' }
function! s:beSource.action_table.open.func(arg)
    let tmpFileName = tempname()

    try
        silent exe 'vertical botright split edit'
        call append(0, s:alignArticle(a:arg.article_data))
        call cursor(1, 1)

        " TODO:バッファ名チェックを追加
        silent file BATTLE_EDITORS
        setlocal fileformat=unix buftype=nofile filetype=text wrap
        silent! %foldopen
    finally
        call delete(tmpFileName)
    endtry
endfunction


" generate unite candidates
function! s:beSource.gather_candidates(args, context)
    if len(a:args) == 0
        return map(s:getPlaneArticleData(), "{
                    \ 'word': v:val.title,
                    \ 'abbr': v:val.title,
                    \ 'kind': 'common',
                    \ 'article_data' : v:val
                    \}")
    endif

    return []
endfunction


function! s:getPlaneArticleData()
    let url = 'http://vinarian.blogspot.jp/rss.xml'

    " 関連記事を保存
    let beArticle = []

    " タイトルから記事一覧を取得
    " item の key は id, link, date, title, content
    for item in webapi#feed#parseURL(url)
        if '' != matchstr(item.title, 'エディターズ')
            call add(beArticle, item)
        endif
    endfor

    return beArticle
endfunction


function! s:alignArticle(artDict)
    " substitute(nled, '<[a-z\/]\+[^>]*>', '', 'g')
    " substitute(nled, '</?^(br)[^><]*>', '', 'g')

    let cleaned = substitute(a:artDict.content, '<\/\=\(br\)\@![^><]*>', '', 'g')
    let splited = split(cleaned, '<br[^>]*>')
    return map(splited, 'webapi#html#decodeEntityReference(v:val)')
endfunction



let &cpo = s:save_cpo
unlet s:save_cpo
