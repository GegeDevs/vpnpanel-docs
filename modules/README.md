# Modules Documentation

### Formating Text

This bot uses HTML Formatting for Message Style but the first line of output must contain `HTML_CODE` in the module output to mark that the text to be sent uses HTML Formatting.

HTML Formating Reference : [Telegram Bot API - HTML Style](https://core.telegram.org/bots/api#html-style)

```bash
echo -e "HTML_CODE"
echo -e "<b>+++++ ${tunnel_name} Account Created +++++</b>"
echo -e "Username: <code>${USERNAME}</code>"
echo -e "Password: <code>${PASSWORD}</code>"
echo -e "Expired: <code>$(date -d "@${expire}" '+%Y-%m-%d %H:%M:%S')</code>"
echo -e "Data Limit: <code>${limit_gb}</code> GB"
echo -e "Link : <code>${link}</code>"
echo -e "<b>+++++ End of Account Details +++++</b>"
```