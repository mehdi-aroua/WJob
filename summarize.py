from transformers import pipeline
import torch
device = "cuda" if torch.cuda.is_available() else "cpu"
print(f"Using device: {device}")

def chunk_text(text, chunk_size=1000):
    return [text[i:i+chunk_size] for i in range(0, len(text), chunk_size)]

def summarize_text(text):
    summarizer = pipeline("summarization", model="sshleifer/distilbart-cnn-6-6")
    chunks = chunk_text(text)
    summaries = [summarizer(chunk, max_length=150, min_length=50, do_sample=False)[0]['summary_text'] for chunk in chunks]
    return " ".join(summaries)
# def summarize_text(text):
#     device = 0 if torch.cuda.is_available() else -1  # 0 = GPU, -1 = CPU
#     summarizer = pipeline("summarization", model="facebook/bart-large-cnn", device=device)
#     summary = summarizer(text, max_length=150, min_length=50, do_sample=False)
#     return summary[0]['summary_text']
