# Resume Management System

这个仓库使用模块化的方法来管理不同版本的简历。

## 文件结构

- `experience_pool.tex`: 所有经历内容的中央存储池
- `resume.cls`: 自定义简历样式类
- `*-resume.tex`: 不同版本的简历主文件

## 简历版本说明

| 文件名 | 语言 | 用途 | 目标公司/岗位类型 |
|--------|------|------|------------------|
| `jobs_resume.tex` | 英文 | 通用求职简历 | 一般工业界职位 |
| `jobs_resume_cn.tex` | 中文 | 通用求职简历 | 中国区工业界职位 |
| `academic_CV.tex` | 英文 | 学术简历 | 学术界、研究院所 |
| `academic_CV_cn.tex` | 中文 | 学术简历 | 中国区学术界、研究院所 |
| `ML-research-jobs.tex` | 英文 | 机器学习研究岗 | ML/AI研究相关 |
| `ML-research-jobs_cn.tex` | 中文 | 机器学习研究岗 | 中国区ML/AI研究 |
| `physicsX-DS-resume.tex` | 英文 | 数据科学岗 | 数据科学、分析师 |
| `resume-sre.tex` | 英文 | SRE工程师 | 运维、DevOps |
| `resume-sre_cn.tex` | 中文 | SRE工程师 | 中国区运维、DevOps |
| `bci-resume.tex` | 英文 | BCI相关岗位 | 脑机接口研究 |
| `cadence-resume.tex` | 英文 | Cadence公司 | 特定公司定制 |
| `long-cv-for-ornl.tex` | 英文 | ORNL详细简历 | 橡树岭国家实验室 |

## 使用方法

### 1. 编辑经历内容

**英文内容**: 在 `experience_pool.tex` 中添加或修改经历块：
```latex
\addExperience{new-experience-key}{
    \textbf{职位名称} \hfill {时间}
    \\
    \textit{公司名称} \hfill \textit{地点}
    \begin{itemize}
        \item 成就描述1
        \item 成就描述2
    \end{itemize}
}
```

**中文内容**: 在 `experience_pool_cn.tex` 中添加或修改经历块：
```latex
\addExperience{new-experience-key-cn}{
    \textbf{职位名称} \hfill {时间}
    \\
    \textit{公司名称} \hfill \textit{地点}
    \begin{itemize}
        \item 成就描述1
        \item 成就描述2
    \end{itemize}
}
```

### 2. 创建新版本简历

**英文简历**:
1. 复制 `jobs_resume.tex` 作为模板
2. 修改个人信息部分
3. 选择合适的经历块：
   ```latex
   \useExperience{experience-key}
   \useExperiences{key1,key2,key3}
   ```

**中文简历**:
1. 复制 `jobs_resume_cn.tex` 作为模板
2. 修改个人信息部分
3. 选择合适的经历块：
   ```latex
   \useExperience{experience-key-cn}
   \useExperiences{key1-cn,key2-cn,key3-cn}
   ```

### 3. 编译简历

**自动编译**: VS Code会根据文件名自动选择编译器
- 英文简历 (`*.tex`): 使用 PDFLaTeX
- 中文简历 (`*_cn.tex`): 使用 XeLaTeX

**手动编译**: 使用 LaTeX Workshop 扩展，按 `Ctrl+Alt+B` 编译

## 版本控制最佳实践

### Git 分支策略
- `main`: 主分支，保存最新稳定版本
- `feature/new-company-name`: 为特定公司定制简历
- `update/experience-pool`: 更新经历内容

### 提交规范
- `feat: 添加新的工作经历`
- `update: 更新项目描述`
- `fix: 修正格式问题`
- `docs: 更新README`

### 标签使用
为重要版本创建标签：
```bash
git tag -a v1.0-google-application -m "Google软件工程师申请版本"
git tag -a v1.1-academic-postdoc -m "学术博后申请版本"
```

## 自动化工作流

### 1. 编译脚本
创建 `.vscode/tasks.json` 用于批量编译所有简历版本

### 2. PDF 输出管理
所有生成的PDF文件存放在 `build/` 目录中，按版本和日期命名

### 3. 备份策略
定期推送到GitHub，重要版本创建Release

## 维护注意事项

1. **经历内容更新**: 
   - 英文内容：每次获得新经历或成就时，及时更新 `experience_pool.tex`
   - 中文内容：同时更新 `experience_pool_cn.tex`，保持中英文内容同步
2. **版本同步**: 确保所有简历版本都使用最新的联系信息
3. **格式一致性**: 保持所有版本的格式风格统一
4. **内容审查**: 定期检查并更新过时的信息
5. **字体支持**: 
   - 英文简历使用PDFLaTeX编译
   - 中文简历使用XeLaTeX编译，需要系统支持中文字体(PingFang SC)

## 快速开始

1. 克隆仓库
2. 安装推荐的VS Code扩展
3. 打开 `experience_pool.tex` 添加你的经历
4. 选择合适的简历模板开始定制
5. 使用 `Ctrl+Alt+B` 编译查看效果
