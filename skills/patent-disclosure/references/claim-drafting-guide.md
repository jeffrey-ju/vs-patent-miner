# Patent Claim Drafting Guide

## Claim Triad (REQUIRED)

Every disclosure needs 3 independent claims:

**Claim 1 — Method:**
```
A computer-implemented method for [function], comprising:
(a) receiving, by a processor, [first input];
(b) computing, by the processor, a first [result] by [technical step];
(c) determining, by the processor, a second [result] based on [technical step]; and
(d) generating, by the processor, [output] based on the first [result] and the second [result].
```

**Claim 2 — System:**
```
A system comprising:
a processor; and
a non-transitory computer-readable medium storing instructions that, when executed by the processor, cause the processor to:
[same steps as method claim].
```

**Claim 3 — CRM:**
```
A non-transitory computer-readable medium storing instructions that, when executed by a processor, cause the processor to perform operations comprising:
[same steps as method claim].
```

Plus 5-10 dependent claims per independent claim.

## Antecedent Basis Rules (CRITICAL)

- First mention uses "a" or "an": `"receiving a goal statement"`
- Subsequent mentions use "the" or "said": `"comparing the goal statement"`
- Every element in a dependent claim must trace back to the parent claim
- Once you call it "goal statement", never switch to "objective text"

**Example fix:**
```
BEFORE: "...comparing the alignment score with the threshold..."
AFTER:  "...comparing a computed alignment score with a predefined threshold..."
```

## Forbidden Language (scan and remove)

| Find | Replace with |
|------|--------------|
| "the invention" | "the disclosed method" |
| "the present invention" | "in some implementations" |
| "obviously" / "simply" / "easily" | Remove entirely |
| "important" / "critical" / "key" (adjectives) | Remove or rephrase |
| "always" / "never" / "must" | "in one embodiment" / "may" / "can" |
| "preferred embodiment" | "in one embodiment" |

## Abstract Rules

**English (USPTO 37 CFR 1.72(b)):**
- Single paragraph, ≤ 150 words
- States what / problem / how
- Uses same terminology as Claim 1
- No forbidden phrases

**Traditional Chinese (TIPO):**
- ≤ 300 characters
- Uses Taiwan terminology (not mainland)
- Formal register (書面語)
- Traditional characters only

## TW Term Mapping

| Mainland (禁用) | Taiwan (使用) |
|-----------------|---------------|
| 算法 | 演算法 |
| 软件 | 軟體 |
| 服务器 | 伺服器 |
| 数据库 | 資料庫 |
| 信息 | 資訊 |
| 接口 | 介面 |
| 缓存 | 快取 |
