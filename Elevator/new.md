**Mục tiêu mô phỏng**

* Tính & vẽ BER cho Fixed‑QAM với

  * $M\in\{4,16,64\}$
  * code rate $r\in\{1/2,\,1\}$
  * Cyclic Prefix $L_{\rm CP}\in\{8,16\}$
* Vẽ constellation tại ba mức $\mathrm{Eb}/N_0 = \{12,18,20\}$ dB (chỉ CP = 16)

---

## 1. QAM Modulation (Fixed‑QAM)

* **M‑QAM orders**:

  $$
    M \in \{4,16,64\},\quad 
    k = \log_{2}M \in \{2,4,6\}
  $$
* **Mapping**: Gray‑coded
* **Normalization**:
  $\displaystyle \mathbb{E}[|s|^2] = 1$

---

## 2. OFDM Parameters

* **FFT size**:

  $$
    N_{\rm FFT} = 64
  $$
* **Subcarriers dữ liệu**:

  $$
    \text{data\_idx} = 7:59 \quad (N_{\rm data} = 53\ \text{subcarriers})
  $$
* **Cyclic Prefix**:

  $$
    L_{\rm CP} \in \{8,\,16\}
  $$

---

## 3. Kênh 3GPP EVA (static)

* **Delays** (ns):
  $\{0,30,150,310,370,710,1090,1730,2510\}$
* **Gains** (dB):
  $\{0.0,-1.5,-1.4,-3.6,-0.6,-9.1,-7.0,-12.0,-16.9\}$
* **Sampling**:

  $$
    f_s = 15.36\ \mathrm{MHz},\quad 
    T_s = 1/f_s
  $$
* **Impulse response length**:

  $$
    h_{\rm len} = \max(\text{tap\_indices}) + 1
  $$
* **Equalization vector**:

  $$
    H_{\rm data} = \mathrm{FFT}_{64}(h)[\,\text{data\_idx}\,]
  $$

---

## 4. Coding & Interleaving

* **Convolutional code**:

  $$
    K=3,\quad g=[7,\,5]_{8},\quad \text{rate}=1/2
  $$
* **Block interleaver**: 2 hàng (chỉ dùng khi $r=1/2$)
* **Code rates**:

  * $r=1/2$ (encode + interleave)
  * $r=1$ (no coding)
