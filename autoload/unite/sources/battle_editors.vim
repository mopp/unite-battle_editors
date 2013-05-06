scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim



let s:beSource = {
            \ 'name' : 'battle_editors',
            \ 'default_action': {'*': 'open'},
            \ 'action_table': {},
            \ }


" define unite source
function! unite#sources#battle_editor#define()
    return s:beSource
endfunction


" define unite action
let s:beSource.action_table.open = { 'description': 'open selected article in buffer' }
function! s:beSource.action_table.open.func(arg)
    let tmpFileName = tempname()

    try
        " echo s:alignArticle(a:arg.article_data)
        call writefile(s:alignArticle(a:arg.article_data), tmpFileName)

        silent exe ':vertical botright split ' tmpFileName
        silent file BATTLE_EDITORS
        setlocal fileformat=unix buftype=nofile filetype=text wrap
        silent! %foldopen
    finally
        call delete(tmpFileName)
    endtry
endfunction


" generate unite candidates
function! s:beSource.gather_candidates(args, context)
    let candidates = []

    if len(a:args) == 0
        for elem in s:getPlaneArticleData()
            call add(candidates, {
                        \ 'word': elem.title,
                        \ 'abbr': elem.title,
                        \ 'kind': 'directory',
                        \ 'article_data' : elem
                        \})
        endfor
    endif

    return candidates
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
