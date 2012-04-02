require "zlib"
require "stemmify"

STOPWORDS = open("data/stopwords").read

def tokenize(string)
  terms = []
  string.downcase.split(/[^a-z_\-<>\/0-9]/).each do |t|
    if STOPWORDS.match(t).nil?
      terms << t.stem
    end
  end
  terms
end

def create_rel_results(filename)
  begin
    File.open("#{filename}.rel", "r").read
    puts "#{filename}.rel already exists..."
  rescue
    puts "Creating #{filename}.rel file..."
    qrel = File.open("data/qrel.txt", "r").read
    output = "#{filename}.rel"
    File.open(filename, "r").each do |line|
      array = tokenize(line)
      # I only care about the top ten results
      if array[3].to_i > 10
        next
      end
      if !qrel.match("#{array[2].upcase} 1").nil?
        # Found and relevant
        File.open(output, "a") { |f| 
          f.write "#{array[0]},#{array[2].upcase},#{array[3]},1\n" }
      elsif !qrel.match("#{array[2].upcase} 0").nil?
        # Found but not relevant
        File.open(output, "a") { |f| 
          f.write "#{array[0]},#{array[2].upcase},#{array[3]},0\n" }
      else
        # Not Found
        File.open(output, "a") { |f| 
          f.write "#{array[0]},#{array[2].upcase},#{array[3]},NF\n" }
      end
    end
  end
end

def build_rel_h(filename)
  rel_h = {}
  File.open("#{filename}.rel", "r") { |f|
    f.each do |line|
      token_a = tokenize(line)
      topic_id = token_a[0].to_i
      if rel_h[topic_id].nil?
        rel_h[topic_id] = []
      end
      rel_h[topic_id] << token_a[3].to_i
    end
  }
  rel_h
end

def evaluate_scores(rel_h)
  # local variables
  _eval = {}
  prec = []
  dcg = []
  sum = 0

  rel_h.each do |a|
    topic_id = a[0]
    a[1].each_with_index do |v,i|
      unless i == 0
        dcg << (v.to_f / Math.log2(i+1).to_f)
      else
        dcg << v
      end
      sum += v
      prec << (sum.to_f / (i+1).to_f)
      if _eval[topic_id].nil?
        _eval[topic_id] = {}
      end
      if i == 0
        _eval[topic_id][:prec_at_1] = v
      end
      if i == 9
        _eval[topic_id][:avg_prec] = prec.mean
        _eval[topic_id][:prec_at_10] = prec.last
        _eval[topic_id][:dcg] = dcg.reduce(:+)
        sum = 0
        prec = []
        dcg = []
      end
    end
    # sort array in descending order to compute NDCG
    a[1].sort_by { |v| -1*v }.each_with_index do |v,i|
      unless i == 0
        dcg << (v.to_f / Math.log2(i+1).to_f)
      else
        dcg << v
      end
      if i == 9
        if dcg.reduce(:+) == 0.0
          _eval[topic_id][:ndcg] = 0.0
        else
          _eval[topic_id][:ndcg] = _eval[topic_id][:dcg] / dcg.reduce(:+)
        end
        dcg = []
      end
    end
  end
  _eval
end

def show(_eval)
  _eval.each do |a|
    puts "#{a[0]}: #{a[1]}"
  end
end

def get_mean_eval(_eval)
  avg_prec = []
  prec_at_1 = []
  prec_at_10 = []
  dcg = []
  ndcg = []
  mean_eval = {}
  _eval.each do |a|
    avg_prec << a[1][:avg_prec]
    prec_at_1 << a[1][:prec_at_1]
    prec_at_10 << a[1][:prec_at_10]
    dcg << a[1][:dcg]
    ndcg << a[1][:ndcg]
  end
  mean_eval[:avg_prec] = avg_prec.mean
  mean_eval[:prec_at_1] = prec_at_1.mean
  mean_eval[:prec_at_10] = prec_at_10.mean
  mean_eval[:dcg] = dcg.mean
  mean_eval[:ndcg] = ndcg.mean
  mean_eval
end
